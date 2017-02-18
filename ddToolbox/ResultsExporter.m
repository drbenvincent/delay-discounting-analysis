classdef ResultsExporter
	%ResultsExporter
	
	
	properties (SetAccess = protected, GetAccess = public)
		CREDIBLE_INTERVAL
	end
	
	%% Private properties
	properties (SetAccess = protected, GetAccess = protected)
		finalTable
		coda
		data
		postPred
		varList
		
		plotOptions
	end
	
	
	methods (Access = public)
		function obj = ResultsExporter(coda, data, postPred, varList, plotOptions)
			% Ideally, we are going to make a table. Each row is a
			% participant/experiment. We have one set of columns related to
			% the model variables, and another related to posterior
			% prediction. These are made separately and then joined.
			% Currently, this only works when the model variables are
			% scalar, we don't yet have support for vector or matrix
			% model variables.
			
			obj.CREDIBLE_INTERVAL = 0.95;
			obj.coda = coda;
			obj.data = data;
			obj.postPred = postPred;
			obj.varList = varList;
			
			obj.plotOptions = plotOptions;
			
			% TODO: fix this workaround to deal with the fact that obj.makeParamEstimateTable()
			% currently fails for non-parametric models
			temp = obj.makeParamEstimateTable();
			if ~isempty(temp)
				
				% TODO This is what we want to execute in all cases
				obj.finalTable = join(...
					obj.makeParamEstimateTable(),...
					obj.makePostPredTable(),...
					'Keys','RowNames');
				
			else
				% TODO this is a workaround
				obj.finalTable = obj.makePostPredTable();
			end
		end
		
		function printToScreen(obj)
			display(obj.finalTable)
		end
		
		function export(obj, savePath, pointEstimateType)
			% TODO: inject the prefix and suffix
			full_export_path_filename = fullfile(savePath,...
				['parameterEstimates_Posterior_' pointEstimateType '.csv']);
			exportTable(obj.finalTable, full_export_path_filename);
		end
		
	end
	
	
	
	methods (Access = private)
		function paramEstimateTable = makeParamEstimateTable(obj)
			paramEstimateTable = obj.coda.exportParameterEstimates(...
				obj.varList.participantLevel,... %obj.varList.groupLevel,...
				obj.data.getIDnames('all'),...
				obj.plotOptions.savePath,...
				obj.plotOptions.pointEstimateType);
			% TEMP: bail out of doing this if we get an error... most
			% likely caused because of 4D param matrix
			if isempty(paramEstimateTable)
				warning('BAILED OUT OF EXPORTING PARAM ESTIMATES')
				finalTable = table();
				return
			end
		end
		
		function postPredTable = makePostPredTable(obj)
			postPredTable = table(obj.postPred.getScores(),...
				obj.calc_percent_predicted_point_estimate(),...
				obj.any_percent_predicted_warnings(),...
				'RowNames', obj.data.getIDnames('experiments'),...
				'VariableNames',{'ppScore' 'percentPredicted' 'warning_percent_predicted'});
			
			if obj.data.isUnobservedPartipantPresent()
				% add extra row of NaN's on the bottom for the unobserved participant
				unobserved = table(NaN, NaN, NaN,...
					'RowNames', obj.data.getIDnames('group'),...
					'VariableNames', postPredTable.Properties.VariableNames);
				
				postPredTable = [postPredTable; unobserved];
			end
		end
		
		function percentPredicted = calc_percent_predicted_point_estimate(obj)
			% Calculate point estimates of perceptPredicted. use the point
			% estimate type that the user specified
			pointEstFunc = str2func(obj.plotOptions.pointEstimateType);
			percentPredicted = cellfun(pointEstFunc,...
				obj.postPred.getPercentPredictedDistribution())';
		end
		
		function pp_warning = any_percent_predicted_warnings(obj)
			ppLowerThreshold = 0.5;
			hdiFunc = @(x) HDIofSamples(x, obj.CREDIBLE_INTERVAL);
			warningFunc = @(x) x(1) < ppLowerThreshold;
			warnOnHDI = @(x) warningFunc( hdiFunc(x) );
			pp_warning = cellfun( warnOnHDI,...
				obj.postPred.getPercentPredictedDistribution())';
		end
	end
end
