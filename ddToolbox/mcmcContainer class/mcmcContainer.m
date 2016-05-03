classdef mcmcContainer < handle
	%mcmcContainer

	properties (Access = public)
		samples
	end

	methods(Abstract, Access = public)
		%convergenceSummary()
		%figUnivariateSummary()
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
			p.addParameter('includeGroupEstimates',true, @islogical);
			p.addParameter('includeCI',true, @islogical);
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
			display(paramEstimateTable)

			%% Export
			savename = fullfile('figs',...
				saveFolder,...
				['parameterEstimates_Posterior_' pointEstimateType '.csv']);
			writetable(paramEstimateTable, savename,...
				'Delimiter','\t',...
				'WriteRowNames',true)
			fprintf('The above table of parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)

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
			[fid, fname] = setupFile(saveFolder);
			MCMCParameterReport();
			RhatInformation(IDnames);
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)

			function [fid, fname] = setupFile(saveFolder)
				ensureFolderExists(fullfile('figs',saveFolder))
				fname = fullfile('figs',saveFolder,['ConvergenceReport.txt']);
				fid=fopen(fname,'w');
				assert(fid~=-1)
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
