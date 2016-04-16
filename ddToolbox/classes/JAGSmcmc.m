classdef JAGSmcmc < mcmcContainer
	%JAGSmcmc

	properties (Access = public)
		stats
		mcmcparams
	end

	methods(Abstract, Access = public)

	end

	methods (Access = public)

		function obj = JAGSmcmc(samples, stats, mcmcparams)
			obj = obj@mcmcContainer(); % create instance of base class

			obj.samples = samples;
			obj.stats = stats;
			obj.mcmcparams = mcmcparams;

		end

		function convergenceSummary(obj,saveFolder,IDnames)

			[fid, fname] = setupFile(saveFolder);
			MCMCParameterReport();
			RhatInformation(IDnames);
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)

			function [fid, fname] = setupFile(saveFolder)
				ensureFolderExists(fullfile('figs',saveFolder))
				fname = fullfile('figs',saveFolder,['ConvergenceReport.txt']);
				fid=fopen(fname,'w');
			end

			function MCMCParameterReport()
				logInfo(fid, 'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
				logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
				logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
				logInfo(fid,'\n\n\n');
			end

			function RhatInformation(IDnames)
				warningFlag = false;
				names = fieldnames(obj.stats.Rhat);
				% loop over fields and report for either single values or
				% multiple values (eg when we have multiple participants)
				for name = each(names)
					% skip posterior predictive variables
					if strcmp(name,'Rpostpred')
						continue
					end
					RhatValues = obj.stats.Rhat.(name);
					logInfo(fid,'\nRhat for: %s.\n',name);
					for i=1:numel(RhatValues)
						if numel(RhatValues)>1
							logInfo(fid,'%s\t', IDnames{i});
						end
						logInfo(fid,'%2.5f\t', RhatValues(i));
						if RhatValues(i)>1.01
							warningFlag = true;
							logInfo(fid,'WARNING: poor convergence');
						end
						logInfo(fid,'\n');
					end
				end
				if warningFlag
					logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
					speak('there were some convergence issues')
				else
					logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
				end
			end
		end

		function figUnivariateSummary(obj, participantNames, variables)
			% create a multi-panel figure (one subplot per variable), each
			% comprisnig of univariate summary stats for all participants.

			figure
			for v = 1:numel(variables)
				subplot(numel(variables),1,v)
				hdiMatrix = [...
					obj.getStats('hdi_low',variables{v})'...
					obj.getStats('hdi_low',[variables{v} '_group']);...
					obj.getStats('hdi_high',variables{v})'...
					obj.getStats('hdi_high',[variables{v} '_group'])];
				plotErrorBars(...
					{participantNames{:}},...
					[...
					obj.getStats('mean',variables{v})'...
					obj.getStats('mean',[variables{v} '_group'])...
					],...
					hdiMatrix,...
					variables{v});
				a=axis;
				axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end


		function plotMCMCchains(obj, variablesToPlot)

			for varName = each(variablesToPlot)

				figure
				latex_fig(16, 12,10)

				mcmcsamples = obj.getSamples(varName);
				mcmcsamples = mcmcsamples.(varName);
				[chains,Nsamples,rows] = size(mcmcsamples);
				hChain=[];
				rhat_all = obj.getStats('Rhat', varName);
				for row=1:rows
					% plot MCMC chains --------------
					hChain(row) = intPlotChain(mcmcsamples(:,:,row), row, rows, varName, rhat_all(row));
					% plot distributions ------------
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
				UnivariateDistribution(samples(:));
			end

		end


		function exportParameterEstimates(obj, level1varNames, level2varNames, IDname, saveFolder, varargin)

% 			p = inputParser;
% 			p.FunctionName = mfilename;
% 			p.addRequired('level1varNames',@iscellstr);
% 			p.addRequired('level2varNames',@iscellstr);
% 			p.addRequired('IDname',@iscellstr);
% 			p.addRequired('saveFolder',@ischar);
% 			%p.addParameter('format','txt', @iscell);
% 			p.addParameter('includeCI',true, @islogical);
%
% 			p.parse(level1varNames, level2varNames, IDname, saveFolder,  varargin{:});

			% TODO: act on includeCI preference. Ie get, or do not get CI's.


			%% participant level
			colHeaderNames = createColumnHeaders(level1varNames);
			paramEstimates = obj.grabParamEstimates(level1varNames);
			paramEstimateTable = array2table(paramEstimates,...
				'VariableNames',colHeaderNames,...
				'RowNames', IDname);

			%% group level
			if ~isempty(level2varNames)
				paramEstimates = obj.grabParamEstimates(level2varNames);
				group_level = array2table(paramEstimates,...
					'VariableNames',colHeaderNames,...
					'RowNames', {'GroupLevelInference'});
				% append tables
				paramEstimateTable = [paramEstimateTable ; group_level];
			end

			%% display to command window
			paramEstimateTable

			%% Export

			savename = fullfile('figs', saveFolder, 'parameterEstimates.csv');
			writetable(paramEstimateTable, savename,...
				'Delimiter','\t',...
				'WriteRowNames',true)
			fprintf('The above table of parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)

			function colHeaderNames = createColumnHeaders(varNames)
				colHeaderNames = {};
				for var = each(varNames)
					colHeaderNames{end+1} = sprintf('%s_mean', var);
					%colHeaderNames{end+1} = sprintf('%s_HDI5', varNames{n});
					%colHeaderNames{end+1} = sprintf('%s_HDI95', varNames{n});
				end
			end
		end

		function data = grabParamEstimates(obj, varNames)
			data=[];
			for n=1:numel(varNames)
				data = [data obj.getStats('mean',varNames{n})];
				%data = [data obj.getStats('hdi_low',varNames{n})];
				%data = [data obj.getStats('hdi_high',varNames{n})];
			end
		end



		%% GET METHODS ----------------------------------------------------
		function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% get all the samples for a given value of the 3rd dimension of
			% samples. Dimensions are:
			% 1. mcmc chain number
			% 2. mcmc sample number
			% 3. index of variable, meaning depends upon context of the
			% model

			[flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
			for field = each(fieldsToGet)
				samples.(field) = flatSamples.(field)(:,index);
			end
		end

		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???
			for field = each(fieldsToGet)
				samples.(field) = vec(obj.samples.(field)(:,:,participant));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [samples] = getSamples(obj, fieldsToGet)
			% This will not flatten across chains
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			for field = each(fieldsToGet)
				if isfield(obj.samples,field)
					samples.(field) = obj.samples.(field);
				end
			end
		end

		function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
			[samples] = obj.getSamples(fieldsToGet);
			% flatten across chains
			for field = each(fieldsToGet)
				samples.(field) = vec(samples.(field));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [columnVector] = getStats(obj, field, variable)
			try
				columnVector = obj.stats.(field).(variable)';
			catch
				columnVector =[];
			end
		end

		function pointEstimates = getParticipantPointEstimates(obj, type, n)
			% TODO: enable cell array input and clean it up, no need for switch statement then
			switch type
				case{'me'}
					mPointEstimates = obj.getStats('mean', 'm');
					cPointEstimates = obj.getStats('mean', 'c');
					epsilonPointEstimates = obj.getStats('mean', 'epsilon');
					alphaPointEstimates = obj.getStats('mean', 'alpha');

					pointEstimates.m = mPointEstimates(n);
					pointEstimates.c = cPointEstimates(n);
					pointEstimates.epsilon = epsilonPointEstimates(n);
					pointEstimates.alpha = alphaPointEstimates(n);

				case{'logk'}
					logkPointEstimates = obj.getStats('mean', 'logk');
					epsilonPointEstimates = obj.getStats('mean', 'epsilon');
					alphaPointEstimates = obj.getStats('mean', 'alpha');

					pointEstimates.logk = logkPointEstimates(n);
					pointEstimates.epsilon = epsilonPointEstimates(n);
					pointEstimates.alpha = alphaPointEstimates(n);
			end

		end


		function [predicted] = getParticipantPredictedResponses(obj, participant)
			% calculate the probability of choosing the delayed reward, for
			% all trials, for a particular participant.
			Rpostpred = obj.samples.Rpostpred;
			% extract samples from the participant
			Rpostpred = squeeze(Rpostpred(:,:,participant,:));
			% flatten over chains
			s = size(Rpostpred);
			participantRpostpredSamples = reshape(Rpostpred, s(1)*s(2), s(3));
			[nSamples,~] = size(participantRpostpredSamples);
			% predicted probability of choosing delayed (response = 1)
			predicted = sum(participantRpostpredSamples,1)./nSamples;
		end

	end

	methods(Static)

		function [samples] = flattenChains(samples, fieldsToGet)
			% collapse the first 2 dimensions of samples (number of MCMC
			% chains, number of MCMC samples)
			for field = each(fieldsToGet)
				temp = samples.(field);
				oldDims = size(temp);
				newDims = [oldDims(1)*oldDims(2) oldDims([3:end])];
				samples.(field) = reshape(temp, newDims);
			end
		end

	end
end
