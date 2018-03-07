classdef WAIC
    %WAIC WAIC object
    %   Extended description here
    
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
			obj.lppd_vec = log( mean( exp(obj.log_lik) , 2) );
			obj.lppd = sum(obj.lppd_vec);
			
			% Calculate effective number of samples, pWAIC
			obj.pWAIC_vec = var(obj.log_lik,0,2);
			obj.pWAIC = sum(obj.pWAIC_vec);
			
			% Calculate WAIC
			obj.WAIC_value = -2 * ( obj.lppd - obj.pWAIC );
			
			% Calculate standard error
			obj.WAIC_vec = -2 * ( obj.lppd_vec - obj.pWAIC_vec );
			obj.WAIC_standard_error = sqrt(obj.nCases)*var(obj.WAIC_vec);
			
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
					dSE(m,1) = sqrt(obj(m).nCases)*var(WAIC_diff);
				end
			end
			% create table
			comparisonTable = table(model, WAIC, pWAIC, dWAIC, SE, dSE, lppd);
			% sort so best models (lowest WAIC) values are at top of table
			comparisonTable = sortrows(comparisonTable,{'WAIC'},{'ascend'});
		end
		
		function plot(obj)
			clf
			
			% First build the comparison table
			comparisonTable = obj.compare();
			
			
			% Now plot stuff
			
			% define y-value positions for each model
			y = [1:1:size(comparisonTable,1)];

			hold on
			
			% in-sample deviance as solid circles
			in_sample_deviance = -2*comparisonTable.lppd;
			isd = plot(in_sample_deviance, y, 'ko', 'MarkerFaceColor','k');
			
			
			
			% WAIC as empty cirlcles, with SE errorbars
			%waic = plot(comparisonTable.WAIC, y, 'ko');
			waic_eb = errorbar(comparisonTable.WAIC,y,comparisonTable.SE,...
				'horizontal',...
				'o',...
				'LineStyle', 'none',...
				'Color', 'k');
			
			% plot dSE models
			waic_diff = errorbar(comparisonTable.dWAIC([2:end])+min(comparisonTable.WAIC),...
				y([2:end])+0.2, comparisonTable.dSE([2:end]),...
				'horizontal',...
				'^',...
				'LineStyle', 'none',...
				'Color', [0.5 0.5 0.5]);
			
			
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