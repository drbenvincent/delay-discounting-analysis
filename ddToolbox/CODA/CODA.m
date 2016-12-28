classdef CODA
	%CODA This class is useful for storing, ploting, and getting
	%information about MCMC samples.
	%   Detailed explanation goes here

    % TODO: make this general, and create a seperate, project-specific subclass with additional methods if I need to do that

	properties (GetAccess = private, SetAccess = private)
		samples % structure. Fields correspond to variables.
		stats	% structure. Fields correspond to stats, subfield correspond to variables
	end

	properties (GetAccess = public, SetAccess = private)
		variableNames % cell array of variables
	end

	%% Public methods
	% NOTE TO SELF: These public methods need to be seen as interfaces to
	% the outside world that are implementation-independent. So thought
	% needs to be given to public methods.
	%
	% These public methods need to be covered by tests.

	methods (Access = public)

        % TODO: be able to create just from samples.
        % TODO: add a makeFromJAGS alternative constructor, just like we have one for Stan

		function obj = CODA(samples, stats) % constructor
			assert(isstruct(samples))
			assert(isstruct(stats))
			
			obj.samples = samples;
			obj.stats = stats;
			obj.variableNames = fieldnames(samples);
			
			% TODO: Check presence of my mcmc-utils code as the plotting relies upon it.
		end

		function paramEstimateTable = exportParameterEstimates(obj,...
				variablesRequested, rowNames, savePath, pointEstimateType, varargin)

			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('variablesRequested',@iscellstr);
			p.addRequired('IDname',@iscellstr);
			p.addRequired('savePath',@ischar);
			p.addParameter('includeGroupEstimates',false, @islogical);
			p.addParameter('pointEstimateType','mean', @(x)any(strcmp(x,{'mean','median','mode'})));
			p.addParameter('includeCI',false, @islogical);
			p.parse(variablesRequested, rowNames, savePath,  varargin{:});

			% TODO: act on includeCI preference. Ie get, or do not get CI's.

			colHeaderNames = createColumnHeaders(...
				p.Results.variablesRequested,...
				p.Results.includeCI,...
				p.Results.pointEstimateType);

			% TODO: FIX THIS FAFF TO DEAL WITH POSSIBLE VECTOR/MATRIX
			% VARIABLES
			errorFlag = false;
			tableEntries = NaN(numel(rowNames), numel(colHeaderNames));
			for n = 1:numel(colHeaderNames)
				vals = obj.grabParamEstimates(...
					p.Results.variablesRequested(n),...
					p.Results.includeCI,...
					p.Results.pointEstimateType);
				if size(vals,2)>1
					warning('CANNOT DEAL WITH VECTOR/MATRIX? VARIABLES YET')
					errorFlag = true;
				else
					tableEntries([1:numel(vals)],n) = vals;
				end
			end

			if ~errorFlag
				paramEstimateTable = array2table(tableEntries,...
					'VariableNames',colHeaderNames,...
					'RowNames', rowNames);
			else
				warning('non-scalar model variables detected: Can''t export these in a table yet')
				% return an empty table
				paramEstimateTable= table();
			end

			function colHeaderNames = createColumnHeaders(varNames,getCI, pointEstimateType)
				colHeaderNames = {};
				for k = 1:numel(varNames)
					colHeaderNames{end+1} = sprintf('%s_%s', varNames{k}, pointEstimateType);
					if getCI
						colHeaderNames{end+1} = sprintf('%s_HDI5', varNames{k});
						colHeaderNames{end+1} = sprintf('%s_HDI95', varNames{k});
					end
				end
			end
		end

		
		%% Plotting methods

		function trellisplots(obj, variablesToPlot)
			assert(iscellstr(variablesToPlot))


			for n = 1:numel(variablesToPlot) % TODO: REMOVE THIS LOOP BY A MAP ?

				% sort figure out
				figure
				latex_fig(16, 12,10)

				% get info
				mcmcsamples = obj.getSamples(variablesToPlot(n));
				mcmcsamples = mcmcsamples.(variablesToPlot{n});
				[chains,Nsamples,rows] = size(mcmcsamples);
				rhat_all = obj.getStats('Rhat', variablesToPlot{n});

                % TODO #166 Unclear what this code is doing 
                % TODO #166 Exact this into a method. Can we use layout() or create_subplots() ?
				% create geometry
				for row = 1:rows
					% traceplot
					start = (6*row)-(6-1);
					axis_handle(row, 1) = subplot(rows,6,[start:(start-1)+(6-1)]);
					% density plot
					axis_handle(row, 2) = subplot(rows,6,row*6);
				end

				% call the plot functions
				for row = 1:rows
					obj.traceplot(axis_handle(row, 1),...
						mcmcsamples(:,:,row),...
						variablesToPlot{n},...
						rhat_all(row));

					obj.densityplot(axis_handle(row, 2),...
						mcmcsamples(:,:,row))
				end

				%x tick only on bottom plot
				set(axis_handle([1:end-1], 1),'XTick',[])
				axis_handle(rows, 1).XLabel.String = 'MCMC sample';

				% link y-axes of all traceplots
				linkaxes(axis_handle(:,1),'xy')

				% link x-axis of all density plots
				linkaxes(axis_handle(:,2),'x')
			end
		end


		function traceplot(obj, targetAxisHandle, samples, paramString, rhat)
			% TODO: make targetAxisHandle an optional input

			assert(ischar(paramString))
			assert(isscalar(rhat))
			assert(ishandle(targetAxisHandle))
			assert(size(samples,3)==1)

			subplot(targetAxisHandle)

			%% plot
			h = plot(samples',...
				'LineWidth',0.5);
			box off

			%% format
			ylabel(sprintf('$$ %s $$', paramString), 'Interpreter','latex')

			%% Add Rhat string
			if ~isempty(rhat), addRhatStringToFigure(targetAxisHandle, rhat), end
		end


		function densityplot(obj, targetAxisHandle, samples)
			% TODO: MAKE targetAxisHandle OPTIONAL
			
			% TODO: check for presence of mcmc. package. If it's not
			% present, then use normal plotting routines
			
			% TODO: make targetAxisHandle an optional input
			if ~isempty(targetAxisHandle)
				subplot(targetAxisHandle)
			end
			
			
% 			% using my plot tools package
% 			mcmc.UnivariateDistribution(samples',...
% 				'plotStyle','hist',...
% 				'plotHDI',false);

univariateObject = Stochastic('name_here');
univariateObject.addSamples(samples);
univariateObject.plot;
		end
		
		
		function plot_univariate_distribution(obj, targetAxisHandle, x_var_name, ind, opts )
			subplot(targetAxisHandle)
			
			x_samples = obj.getSamplesAtIndex(ind, x_var_name);
			
			mcmc.UnivariateDistribution(...
				x_samples.(x_var_name{:}),... % TODO: avoid this faff, but getting as a matrix in the first place
				'xLabel', x_var_name{:},...
				'pointEstimateType',opts.pointEstimateType,...
				'plotStyle', 'hist',...
				'axisSquare', true);
		end
		
		function plot_bivariate_distribution(obj, targetAxisHandle, x_var_name, y_var_name, ind, opts )
			subplot(targetAxisHandle)
			
			x_samples = obj.getSamplesAtIndex(ind, x_var_name);
			y_samples = obj.getSamplesAtIndex(ind, y_var_name);
			
			
			mcmc.BivariateDistribution(...
				x_samples.(x_var_name{:}),... % TODO: avoid this faff, but getting as a matrix in the first place
				y_samples.(y_var_name{:}),... % TODO: avoid this faff, but getting as a matrix in the first place
				'xLabel', x_var_name{:},...
				'ylabel', y_var_name{:},...
				'pointEstimateType',opts.pointEstimateType,...
				'plotStyle', 'hist',...
				'axisSquare', true);
		end


		%% Get methods

		function data = grabParamEstimates(obj, varNames, getCI, pointEstimateType)
			assert(islogical(getCI))
			data=[];
			for n=1:numel(varNames)
				data = [data obj.getStats(pointEstimateType,varNames{n})];
				if getCI
					data = [data obj.getStats('hdi_low',varNames{n})];
					data = [data obj.getStats('hdi_high',varNames{n})];
				end
			end
		end

		function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
			assert(iscellstr(fieldsToGet),'arguments needs to be a cell array of strings')
			assert(isnumeric(index), 'argument needs to be numeric')
			% get all the samples for a given value of the 3rd dimension of
			% samples. Dimensions are:
			% 1. mcmc chain number
			% 2. mcmc sample number
			% 3. index of variable, meaning depends upon context of the
			% model

			[flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
			for n = 1:numel(fieldsToGet)
				try
					samples.(fieldsToGet{n}) = flatSamples.(fieldsToGet{n})(:,index,:);
				catch
					samples.(fieldsToGet{n}) = NaN;
				end
			end
		end
		
		function [samplesMatrix] = getSamplesFromExperimentAsMatrix(obj, experiment, fieldsToGet)
			assert(iscellstr(fieldsToGet))
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???
			for n = 1:numel(fieldsToGet)
				try
					samples.(fieldsToGet{n}) = vec(obj.samples.(fieldsToGet{n})(:,:,experiment));
				catch
					samples.(fieldsToGet{n}) = NaN;
				end
			end
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [samples] = getSamples(obj, fieldsToGet)
			% Doesn't flatten across chains
			assert(iscellstr(fieldsToGet))
			fieldsToGet = ismember(fieldnames(obj.samples), fieldsToGet);
			samples		= filterFields(fieldsToGet, obj.samples);
		end

		function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
			% TODO: this makes assumptions, which are not true. Add checks or robustify.
			samplesMatrix = struct2Matrix( obj.flattenChains(obj.samples, fieldsToGet) );
		end

		function [columnVector] = getStats(obj, field, variable)
			% TODO: check requested field exists in stats
			try
				if isempty(variable)
					columnVector = obj.stats.(field);
				else
					columnVector = obj.stats.(field).(variable)';
				end
			catch
				columnVector =[];
			end
		end

		function pointEstimates = getPointEstimates(obj, n, variableNames)
			assert(iscellstr(variableNames))
			for var = each(variableNames)
				temp = obj.getStats('mean', var);
				pointEstimates.(var) = temp(n);
			end
		end

		function [predicted] = getParticipantPredictedResponses(obj, ind)
			% ind is a binary valued vector indicating the trials
			% corresponding to a particular participant
			assert(isvector(ind))

			RpostPred = obj.samples.Rpostpred(:,:,ind);
			participantRpostpredSamples = collapseFirstTwoColumnsOfMatrix(RpostPred);
			%s = size(RpostPred);
			%participantRpostpredSamples = reshape(RpostPred, s(1)*s(2), s(3));

			% Calculate predicted response probability
			predicted = sum(participantRpostpredSamples,1) ./ size(participantRpostpredSamples,1);
		end

		function [PChooseDelayed] = getPChooseDelayed(obj, pInd)
			PChooseDelayed = obj.samples.P(:,:,pInd);
			PChooseDelayed = collapseFirstTwoColumnsOfMatrix(PChooseDelayed)';
		end

	end

	%% Alternate constructors
	methods (Static)
		function obj = buildFromStanFit(stanFitObject)
            % TODO: add an assert about the type of object being passed in
			samples = stanFitObject.extract('collapseChains', false, 'permuted', false);
			stats	= computeStats(samples);
			obj		= CODA(samples, stats);
		end
		
	end

	%% PRIVATE METHODS ====================================================
	% Not to be covered by tests, unless it is useful during development.
	% But we do not need tests to constrain the way how these
	% implementation details work.

	methods(Static, Access = private)

		function [new_samples] = flattenChains(samples, fieldsToGet)
			assert(isstruct(samples))
			assert(iscellstr(fieldsToGet))
			fieldsToGet = ismember(fieldnames(samples), fieldsToGet);
			samples		= filterFields(fieldsToGet, samples);
			new_samples = structfun(@collapseFirstTwoColumnsOfMatrix, samples, 'UniformOutput', false);
		end

	end

end
