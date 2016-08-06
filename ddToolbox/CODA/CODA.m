classdef CODA
	%CODA Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (GetAccess = private, SetAccess = private)
		samples % structure. Fields correspond to variables.
		stats	% structure. Fields correspond to stats, subfield correspond to variables
	end
	
	% NOTE TO SELF: These public methods need to be seen as interfaces to
	% the outside world that are implementation-independent. So thought
	% needs to be given to public methods.
	%
	% These public methods need to be covered by tests.
	
	methods (Access = public)
		
		function obj = CODA(samples, stats) % constructor
			% This is the main constructor function.
			
			% Validate samples
			assert(isstruct(samples))
			
			obj.samples = samples;
			obj.stats = stats;
		end
		
		
		% TODO: REMOVE OR MAKE IT GENERAL
		function paramEstimateTable = exportParameterEstimates(obj,...
				level1varNames, IDname, saveFolder, pointEstimateType, varargin)
			% make a Table. Rows correspond to "IDname", columns
			% correspond to those in "level1varNames".
			% Note: some variables may not have an entry for the
			% "unobserved participant".
			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('level1varNames',@iscellstr);
			p.addRequired('IDname',@iscellstr);
			p.addRequired('saveFolder',@ischar);
			p.addParameter('includeGroupEstimates',false, @islogical);
			p.addParameter('includeCI',false, @islogical);
			p.parse(level1varNames, IDname, saveFolder,  varargin{:});
			
			% TODO: act on includeCI preference. Ie get, or do not get CI's.
			
			colHeaderNames = createColumnHeaders(level1varNames, p.Results.includeCI, pointEstimateType);
			
			% TODO: FIX THIS FAFF TO DEAL WITH POSSIBLE VECTOR/MATRIX
			% VARIABLES
			errorFlag = false;
			tableEntries = NaN(numel(IDname), numel(colHeaderNames));
			for n = 1:numel(colHeaderNames)
				vals = obj.grabParamEstimates(level1varNames(n), p.Results.includeCI, pointEstimateType);
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
					'RowNames', IDname);
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
		
		
		function plotMCMCchains(obj, variablesToPlot)
			assert(iscellstr(variablesToPlot))
			for n = 1:numel(variablesToPlot)
				figure
				latex_fig(16, 12,10)
				mcmcsamples = obj.getSamples(variablesToPlot(n));
				mcmcsamples = mcmcsamples.(variablesToPlot{n});
				[chains,Nsamples,rows] = size(mcmcsamples);
				hChain=[];
				rhat_all = obj.getStats('Rhat', variablesToPlot{n});
				for row=1:rows
					hChain(row) = intPlotChain(mcmcsamples(:,:,row), row, rows, variablesToPlot{n}, rhat_all(row));
					intPlotDistribution(mcmcsamples(:,:,row), row, rows)
				end
				linkaxes(hChain,'x')
			end
			
			function hChain = intPlotChain(samples, row, rows, paramString, rhat)
				assert(size(samples,3)==1)
				% select the right subplot
				start = (6*row)-(6-1);
				hChain = subplot(rows,6,[start:(start-1)+(6-1)]);
				% plot
				h = plot(samples', 'LineWidth',0.5);
				% format
				ylabel(sprintf('$$ %s $$', paramString), 'Interpreter','latex')
				str = sprintf('$$ \\hat{R} = %1.5f$$', rhat);
				hText = addTextToFigure('T',str, 10, 'latex');
				if rhat<1.01
					hText.BackgroundColor=[1 1 1 0.7];
				else
					hText.BackgroundColor=[1 0 0 0.7];
				end
				box off
				if row~=rows
					set(gca,'XTick',[])
				end
				if row==rows
					xlabel('MCMC sample')
				end
			end
			
			function intPlotDistribution(samples, row, rows)
				hHist = subplot(rows,6,row*6);
				mcmc.UnivariateDistribution(samples(:)); % using my plot tools package
			end
			
		end
		
		
		% -----------------------------------------------------------------
		% PUBLIC GET METHODS
		% -----------------------------------------------------------------
		
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
			assert(iscellstr(fieldsToGet))
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
		
		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscellstr(fieldsToGet))
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???
			for n = 1:numel(fieldsToGet)
				try
					samples.(fieldsToGet{n}) = vec(obj.samples.(fieldsToGet{n})(:,:,participant));
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
			% TODO: this makes assumptions, which are not true. Add checks,
			% or robustify.
			samplesMatrix = struct2Matrix( obj.flattenChains(obj.samples, fieldsToGet) );
		end
		
		function [columnVector] = getStats(obj, field, variable)
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
		
		function pointEstimates = getParticipantPointEstimates(obj, n, variableNames)
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
	
	
	% -----------------------------------------------------------------
	% PUBLIC, ALTERNATE CONSTRUCTORS
	% -----------------------------------------------------------------
	methods (Static)
		function obj = buildFromStanFit(stanFitObject)
			samples = stanFitObject.extract('collapseChains', false, 'permuted', false);
			stats	= computeStats(samples);
			obj		= CODA(samples, stats);
		end
	end
	
	
	% PRIVATE =============================================================
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