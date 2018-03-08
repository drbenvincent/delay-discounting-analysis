classdef WAIC
    %WAIC WAIC object
    % The WAIC object is intended to help conduct Bayesian model 
	% comparison. 
	% 
	% Step 1: Create a WAIC object for each model we have. We do this by
	% creating a WAIC instance, calling it with a table of log likeliood
	% values. Each column corresponds to an MCMC sample, and each row
	% corresponds to an observation. Creating a single WAIC object will
	% result in various stats being calculated, but the intention is to
	% compare mulitple models.
	%
	% We do this by creating an array of WAIC objects, one for each model.
	% For example, assuming we already have our log liklihood tables
	% produced by 3 models...
	% >> waic_stats = [WAIC(ll1,'m1'), WAIC(ll2,'m2'), WAIC(ll3,'m3')]
	% 
	% Step 2: compare
	% We now have an object array, and we can call the compare or plot
	% methods on this. For example
	% >> comparison_table = waic_stats.compare()
	% will produce a table of WAIC comparison stats.
	%
	% and
	% >> waic_stats.plot()
	% will produce a nicely formatted
    %
	% References
	% Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., 
	% & Rubin, D. B. (2013). Bayesian Data Analysis, Third Edition. 
	% CRC Press.
	%
	% McElreath, R. (2016). Statistical Rethinking: A Bayesian Course with 
	% Examples in R and Stan. CRC Press.
	
    properties (SetAccess = protected)
		lppd, pWAIC, WAIC_value, WAIC_standard_error
		nSamples, nCases
	end
	
	properties (Hidden = true, SetAccess = protected)
		log_lik
		lppd_vec, pWAIC_vec, WAIC_vec
	end
    
	properties
		model_name
	end
	
    methods
        
        function obj = WAIC(log_lik, model_name)
			% WAIC constructor. The input log_lik should be a table of log
			% likelihood values. Each column corresponds to an MCMC sample,
			% and each row corresponds to an observation
			
			[obj.nCases, obj.nSamples] = size(log_lik);
			obj.model_name = model_name;
			obj.log_lik = log_lik; clear log_lik
			
			% Calculate lppd
			% Equation 7.5 from Gelman et al (2013) 
			obj.lppd_vec = log( mean( exp(obj.log_lik) , 2) );
			obj.lppd = sum(obj.lppd_vec);
			
			% Calculate effective number of samples, pWAIC
			% Equation 7.12 from Gelman et al (2013) 
			obj.pWAIC_vec = var(obj.log_lik,0,2);
			obj.pWAIC = sum(obj.pWAIC_vec);
			
			% Calculate WAIC
			obj.WAIC_value = calc_waic(obj.lppd, obj.pWAIC);
			
 			% Calculate WAIC standard error
			obj.WAIC_vec = calc_waic(obj.lppd_vec, obj.pWAIC_vec);   
			obj.WAIC_standard_error = standard_error(obj.WAIC_vec);
		end
		
		function comparisonTable = compare(obj)
			% Compare WAIC info from mulitple models
			assert(numel(obj)>1, 'expecting an array of >1 WAIC object')
			
			% Build a table of values
			model = {obj.model_name}';
			WAIC = [obj.WAIC_value]';
			pWAIC = [obj.pWAIC]';
			lppd = [obj.lppd]';
			SE = [obj.WAIC_standard_error]';
			dWAIC = WAIC - min(WAIC);
			weight = exp(-0.5.*dWAIC) ./ sum(exp(-0.5.*dWAIC));
			
			% dSE is the SE of the difference in WAIC (not SE!) between 
			% each model and the top ranked model
			[~, i_best_model] = min([obj.WAIC_value]);
			for m = 1:numel(obj)
				if m == i_best_model
					dSE(m,1) = NaN;
				else
					% Calculate SE of difference (of WAIC values) between
					% model m and i_best_model
					WAIC_diff = obj(i_best_model).WAIC_vec - obj(m).WAIC_vec;
					dSE(m,1) = standard_error(WAIC_diff);
				end
			end
			% create table
			comparisonTable = table(model, WAIC, pWAIC, dWAIC, weight, SE, dSE, lppd);
			% sort so best models (lowest WAIC) values are at top of table
			comparisonTable = sortrows(comparisonTable,{'WAIC'},{'ascend'});
		end
		
		function plot(obj)
			% produce a WAIC comparison plot
			
			comparisonTable = obj.compare();
			
			% define y-value positions for each model
			y = [1:1:size(comparisonTable,1)];

			% set plot options
			marker_size = 7;
			grey_col = [0.5, 0.5, 0.5];
			
			clf
			hold on
			
			% in-sample deviance as solid circles
			in_sample_deviance = -2*comparisonTable.lppd;
			isd = plot(in_sample_deviance, y, 'ko',...
				'MarkerFaceColor','k',...
				'MarkerSize', marker_size);
			
			% WAIC as empty cirlcles, with SE errorbars
			waic_eb = errorbar(comparisonTable.WAIC,y,comparisonTable.SE,...
				'horizontal',...
				'o',...
				'LineStyle', 'none',...
				'Color', 'k',...
				'MarkerFaceColor','w',...
				'MarkerSize', marker_size);
			
			% plot WAIC as compared to best model, in a different colour
			waic_diff = errorbar(comparisonTable.dWAIC([2:end])+min(comparisonTable.WAIC),...
				y([2:end])-0.2, comparisonTable.dSE([2:end]),...
				'horizontal',...
				'^',...
				'LineStyle', 'none',...
				'Color', grey_col,...
				'MarkerFaceColor','w',...
				'MarkerSize', marker_size);
			
			% formatting
			xlabel('deviance');
			set(gca,...
				'YTick', y,...
				'YTickLabel', comparisonTable.model,...
				'YDir','reverse');
			ylim([min(y)-1, max(y)+1]);
			
			vline(min(comparisonTable.WAIC), 'Color', grey_col);
			
			legend([isd, waic_eb, waic_diff],...
				{'in-sample deviance', 'WAIC (+/- SE)', 'WAIC difference (+/- SE)'},...
				'location', 'eastoutside');
			
			title('WAIC Model Comparison')

		end
        
	end
    
end

function SE = standard_error(x)
SE = sqrt(numel(x))*std(x);
end

function waic = calc_waic(lppd, pWAIC)
waic = -2 * lppd + 2 * pWAIC;
end