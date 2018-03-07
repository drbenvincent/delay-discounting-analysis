classdef WAIC
    %WAIC WAIC object
    %   Extended description here
    %
	% References
	% Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., 
	% & Rubin, D. B. (2013). Bayesian Data Analysis, Third Edition. 
	% CRC Press.
    properties (SetAccess = protected)
		lppd, pWAIC, WAIC_value, WAIC_standard_error
		nSamples, nCases
	end
	
	properties (Hidden = true)
		log_lik
		lppd_vec, pWAIC_vec, WAIC_vec
		modelName
	end
    
    methods
        
        function obj = WAIC(log_lik)
			
			[obj.nCases, obj.nSamples] = size(log_lik);
			
			obj.log_lik = log_lik;
			clear log_lik
			
			% Calculate lppd
			% Equation 7.5 from Gelman et al (2013) 
			obj.lppd_vec = log( mean( exp(obj.log_lik) , 2) );
			obj.lppd = sum(obj.lppd_vec);
			
			% Calculate effective number of samples, pWAIC
			% Equation 7.12 from Gelman et al (2013) 
			obj.pWAIC_vec = var(obj.log_lik,0,2);
			obj.pWAIC = sum(obj.pWAIC_vec);
			
			% Calculate WAIC
			obj.WAIC_value = -2 * obj.lppd + 2 * obj.pWAIC;
			
			% Calculate WAIC standard error
			obj.WAIC_vec = -2 * obj.lppd_vec + 2 * obj.pWAIC_vec;
			obj.WAIC_standard_error = sqrt(obj.nCases)*std(obj.WAIC_vec);
			
		end
		
		function comparisonTable = compare(obj)
			% Compare WAIC info from mulitple models
			assert(numel(obj)>1, 'expecting an array of >1 WAIC object')
			
			% Build a table of values
			model = {obj.modelName}';
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
					dSE(m,1) = sqrt(obj(m).nCases)*std(WAIC_diff);
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

			ms = 6;
			clf
			hold on
			
			% in-sample deviance as solid circles
			in_sample_deviance = -2*comparisonTable.lppd;
			isd = plot(in_sample_deviance, y, 'ko',...
				'MarkerFaceColor','k',...
				'MarkerSize', ms);
			
			% WAIC as empty cirlcles, with SE errorbars
			%waic = plot(comparisonTable.WAIC, y, 'ko');
			waic_eb = errorbar(comparisonTable.WAIC,y,comparisonTable.SE,...
				'horizontal',...
				'o',...
				'LineStyle', 'none',...
				'Color', 'k',...
				'MarkerFaceColor','w',...
				'MarkerSize', ms);
			
			% plot dSE models
			waic_diff = errorbar(comparisonTable.dWAIC([2:end])+min(comparisonTable.WAIC),...
				y([2:end])-0.2, comparisonTable.dSE([2:end]),...
				'horizontal',...
				'^',...
				'LineStyle', 'none',...
				'Color', [0.5 0.5 0.5],...
				'MarkerFaceColor','w',...
				'MarkerSize', ms);
			
			% formatting
			xlabel('deviance');
			set(gca,...
				'YTick', y,...
				'YTickLabel', comparisonTable.model,...
				'YDir','reverse');
			ylim([min(y)-1, max(y)+1]);
			
			vline(min(comparisonTable.WAIC), 'Color',[0.5 0.5 0.5]);
			
			legend([isd, waic_eb, waic_diff],...
				{'in-sample deviance', 'WAIC (+/- SE)', 'SE of WAIC difference (+/- SE)'},...
				'location', 'eastoutside');
			
			title('WAIC Model Comparison')

		end
        
	end
    
end