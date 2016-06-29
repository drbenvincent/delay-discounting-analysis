classdef mcmcContainer < handle
	%mcmcContainer lass contains MCMC samples and has a number of methods
	%that operate on those samples.
	%
	% - exportParameterEstimates()
	% - convergenceSummary()
	% - figUnivariateSummary()
	% - plotMCMCchains()
	%
	% And concrete class implemetations must also have a bunch of get
	% methods:
	% - getStats()
	% - getSamplesAsMatrix()
	% - getSamples()
	% - getSamplesFromParticipantAsMatrix()
	% - getSamplesAtIndex()

	% This is an interface class, and must be implemented by concrete
	% classes

% TODO: We should really just have ONE mcmcContainer class and we should be
% able to get samples from both JAGS and STAN into that.
% But if STAN / MatlabStan have their own mcmc classes then it seems unwise
% to make my own. Better explore the STAN angle first and then recap.


	properties (Access = public)
		samples
	end

	methods(Abstract, Access = public)
		getStats()
		getSamplesAsMatrix()
		getSamples()
		getSamplesFromParticipantAsMatrix()
		getSamplesAtIndex()
	end

	methods (Access = public)

		function obj = mcmcContainer()
		end


		function paramEstimateTable = exportParameterEstimates(obj,...
				level1varNames, level2varNames, IDname, saveFolder, pointEstimateType, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('level1varNames',@iscellstr);
			p.addRequired('level2varNames',@iscellstr);
			p.addRequired('IDname',@iscellstr);
			p.addRequired('saveFolder',@ischar);
			p.addParameter('includeGroupEstimates',false, @islogical);
			p.addParameter('includeCI',false, @islogical);
			p.parse(level1varNames, level2varNames, IDname, saveFolder,  varargin{:});

			% TODO: act on includeCI preference. Ie get, or do not get CI's.


			%% participant level
			colHeaderNames = createColumnHeaders(level1varNames, p.Results.includeCI, pointEstimateType);
			paramEstimates = obj.grabParamEstimates(level1varNames, p.Results.includeCI, pointEstimateType);
			paramEstimateTable = array2table(paramEstimates,...
				'VariableNames',colHeaderNames,...
				'RowNames', IDname);

			%% group level
			if ~isempty(level2varNames) && p.Results.includeGroupEstimates
				paramEstimates = obj.grabParamEstimates(level2varNames, p.Results.includeCI, pointEstimateType);
				group_level = array2table(paramEstimates,...
					'VariableNames',colHeaderNames,...
					'RowNames', {'GroupLevelInference'});
				% append tables
				paramEstimateTable = [paramEstimateTable ; group_level];
			end

			%% display to command window
			%display(paramEstimateTable)

			function colHeaderNames = createColumnHeaders(varNames,getCI, pointEstimateType)
				colHeaderNames = {};
				for var = each(varNames)
					colHeaderNames{end+1} = sprintf('%s_%s', var, pointEstimateType);
					if getCI
						colHeaderNames{end+1} = sprintf('%s_HDI5', var);
						colHeaderNames{end+1} = sprintf('%s_HDI95', var);
					end
				end
			end
		end


		function convergenceSummary(obj,saveFolder,IDnames)
			[fid, fname] = setupTextFile(saveFolder, 'ConvergenceReport.txt');
			MCMCParameterReport();
			printRhatInformation(IDnames);
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)


			function MCMCParameterReport()
				logInfo(fid,'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
				logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
				logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
				logInfo(fid,'\n\n\n');
			end

			function printRhatInformation(IDnames)
				nParticipants = numel(IDnames);
				rhatThreshold = 1.01;
				isRhatThresholdExceeded = false;
				varNames = fieldnames(obj.stats.Rhat);

				for varName = each(varNames)
					% skip posterior predictive variables
					if strcmp(varName,'Rpostpred'), continue, end
					RhatValues = obj.stats.Rhat.(varName);

					% conditions
					isVectorOfParticipants = @(x,p) isvector(x) && numel(x)==p;
					isVecorForEachParticipant = @(x,p) ismatrix(x) && size(x,1)==p;

					if isscalar(RhatValues)
						logInfo(fid,'\nRhat for: %s\t',varName);
						logInfo(fid,'%2.5f', RhatValues);
					elseif isVectorOfParticipants(RhatValues,nParticipants)
						logInfo(fid,'\nRhat for: %s\n',varName);
						for i=1:numel(IDnames)
							logInfo(fid,'%s:\t', IDnames{i}); % participant name
							logInfo(fid,'%2.5f\t', RhatValues(i));
							checkRhatExceedThreshold(RhatValues(i));
							logInfo(fid,'\n');
						end
					elseif isVecorForEachParticipant(RhatValues,nParticipants)
						logInfo(fid,'\nRhat for: %s\n',varName);
						for i=1:numel(IDnames)
							logInfo(fid,'%s\t', IDnames{i}); % participant name
							logInfo(fid,'%2.5f\t', RhatValues(i,:));
							checkRhatExceedThreshold(RhatValues);
							logInfo(fid,'\n');
						end
					end
				end

				if isRhatThresholdExceeded
					logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
					speak('there were some convergence issues')
				else
					logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
				end

				function checkRhatExceedThreshold(RhatValues)
					if any(RhatValues>rhatThreshold)
						isRhatThresholdExceeded = true;
						logInfo(fid,'(WARNING: poor convergence)');
					end
				end

			end


		end



		function figUnivariateSummary(obj, participantNames, variables, pointEstimateType)
			% create a multi-panel figure (one subplot per variable), each
			% comprising of univariate summary stats for all participants.
			warning('TODO: Make use of pointEstimateType option.')
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
					obj.getStats(pointEstimateType,variables{v})'...
					obj.getStats(pointEstimateType,[variables{v} '_group'])...
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

				mcmcsamples = obj.getSamples({varName});
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
				mcmc.UnivariateDistribution(samples(:));
			end

		end

  end

end
