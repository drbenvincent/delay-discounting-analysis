classdef ResultsExporter
	%ResultsExporter


	properties (SetAccess = protected, GetAccess = public)
		CREDIBLE_INTERVAL
	end

	%% Private properties
	properties (SetAccess = protected, GetAccess = protected)
		finalTable, alternativeTable
		coda
		data
		postPred
		varList

		plotOptions
	end


	methods (Access = public)

		function obj = ResultsExporter(coda, data, aucTable, postPred, varList, plotOptions)
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
					obj.postPred.getPostPredTable(),...
					'Keys','RowNames');

				% We want to do an outer join here, using RowNames as the
				% keys. However `outerjoin` doesn't allow for this (yet?)
				% so I'm going to have to fart about doing it myself
				%
				% What I want to do...
				% 				obj.finalTable = outerjoin(...
				% 					obj.finalTable,...
				% 					aucTable,...
				% 					'Keys','RowNames');
				%
				% My workaround:

				% note aucTable will be empty in situations where we don't
				% have any auc information, ie for 2-dimensional discount
				% functions
				if ~isempty(aucTable)
					obj.finalTable = myTableOuterJoin(obj.finalTable, aucTable);
				end

				%% make obj.alternativeTable
				% If we also have presence of data.metaTable, we are going
				% to produce another table to output, which appends the
				% point estimates and posterior predictive checks etc onto
				% the metaTable

				% remove 'GROUP' row, if it exists
				GROUPNAME = 'GROUP';
				final_group_removed = obj.finalTable;
				%match_vec = strmatch(GROUPNAME,final_group_removed.Row);
				match_vec = strmatch(GROUPNAME,final_group_removed.Properties.RowNames);
				final_group_removed(match_vec,:) = [];

				metaTable = data.getMetaTable;
				if height(metaTable)>0
					obj.alternativeTable = join(...
						data.getMetaTable,...
						obj.finalTable,...
						'Keys','RowNames');
				end

			else
				% TODO this is a workaround
				obj.finalTable = obj.postPred.getPostPredTable();
			end
		end

		function printToScreen(obj)
			disp(obj.finalTable)
		end

		function export(obj, savePath, pointEstimateType)
			% TODO: inject the prefix and suffix
			full_export_path_filename = fullfile(savePath,...
				'parameterEstimates.csv');
			exportTable(obj.finalTable, full_export_path_filename);

			if ~isempty(obj.alternativeTable)
				full_export_path_filename = fullfile(savePath,...
					'parameterEstimates_ALT.csv');
				exportTable(obj.alternativeTable, full_export_path_filename);
			end
		end

		function results = getResults(obj)
			results = obj.alternativeTable;
		end

	end


	methods (Access = private)

		% TODO: this need to be a method of a new subclass of CODA ??
		function paramEstimateTable = makeParamEstimateTable(obj)
			paramEstimateTable = obj.coda.buildParameterEstimateTable(...
				obj.varList.participantLevel,... %obj.varList.groupLevel,...
				obj.data.getIDnames('all'),...
				obj.plotOptions.savePath,...
				obj.plotOptions.pointEstimateType);
			% TEMP: bail out of doing this if we get an error... most
			% likely caused because of 4D param matrix
			if isempty(paramEstimateTable)
				warning('BAILED OUT OF EXPORTING PARAM ESTIMATES')
				paramEstimateTable = table();
				return
			end
		end

	end
end
