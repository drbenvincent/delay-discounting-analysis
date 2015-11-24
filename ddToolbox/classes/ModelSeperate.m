classdef ModelSeperate < ModelSimple
	%ModelSeperate A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties
		
	end
	
	
	methods (Access = public)
		% =================================================================
		function obj = ModelSeperate(toolboxPath)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@ModelSimple(toolboxPath);
			
			% Overwrite
			obj.JAGSmodel = [toolboxPath '/jagsModels/seperateME.txt'];
			
			obj.modelType = 'mSeparate';
			obj = obj.setMCMCparams();
		end
		% =================================================================
		

		function plot(obj, data)
			close all
			
			% Define limits for each of the variables here for plotting
			% purposes
			obj.range.epsilon=[0 min([prctile(obj.samples.epsilon(:),[99]) , 0.5])];
			%obj.range.alpha=[0 max(obj.samples.alpha(:))];
			obj.range.alpha=[0 prctile(obj.samples.alpha(:),[99])];
			% ranges for m and c to contain ALL samples.
			%obj.range.m=[min(obj.samples.m(:)) max(obj.samples.m(:))];
			%obj.range.c=[min(obj.samples.c(:)) max(obj.samples.c(:))];
			% zoom to contain virtually all samples.
			obj.range.m=prctile(obj.samples.m(:),[1 99]);
			obj.range.c=prctile(obj.samples.c(:),[1 99]);
			
			
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			figGroupedForestPlotSeparate(obj.analyses.univariate)
			%stackedForestPlot(obj.analyses.univariate)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------
			
			obj.figParticipantLevelWRAPPER(data)
			
			obj.MCMCdiagnostics(data)
		end
		

		function myHDIboxplotWrapper(obj, data)
			
			figure
			participants = data.nParticipants;
			for n=1:participants, labels{n} = num2str(n); end
			
			%% M
			[chains, samples, participants] = size(obj.samples.m);
			M=[reshape(obj.samples.m, [chains*samples, participants])];
			
			subplot(4,1,1)
			HDIboxplot(M, '$m$', labels);
			hline(0, 'Color','k',...
				'LineWidth',1,...
				'LineStyle',':')
			title('Independent inference')
			%% C
			[chains, samples, participants] = size(obj.samples.c);
			C=[reshape(obj.samples.c, [chains*samples, participants])];
			
			subplot(4,1,2)
			HDIboxplot(C, '$c$', labels);
			
			%% LAPSE RATE
			clear labels
			for n=1:participants, labels{n} = num2str(n); end
			
			[chains, samples, participants] = size(obj.samples.lr);
			LR=[reshape(obj.samples.lr, [chains*samples, participants])];
			
			subplot(4,1,3)
			HDIboxplot(LR, '$ \epsilon $', labels);
			set(gca,'XLim',[-0.5 participants+0.5])
			
			%% COMPARISON ACUITY
			clear labels
			for n=1:participants, labels{n} = num2str(n); end
			
			[chains, samples, participants] = size(obj.samples.alpha);
			ALPHA=[reshape(obj.samples.alpha, [chains*samples, participants])];
			
			subplot(4,1,4)
			HDIboxplot(ALPHA, '$ \alpha $', labels);
			set(gca,'XLim',[-0.5 participants+0.5])
			
			%% EXPORTING
			
			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(data.saveName, [], '-summary')
			% -------------------------------
			
		end
		
		
		function MCMCdiagnostics(obj, data)
			% Choose what to plot ---------------
			variablesToPlot = {'epsilon', 'alpha', 'm', 'c'};
			supp			= {[0 0.5], 'positive', [], []};
			paramString		= {'\epsilon', '\alpha', 'm', 'c'};
			
			true=[];
			
			% PLOT -------------------
			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				true,...
				variablesToPlot, supp, paramString, data,...
				obj.modelType);
		end
		
		
		function exportParameterEstimates(obj, data)
			participant_level = array2table(...
				[obj.analyses.univariate.m.mode'...
				obj.analyses.univariate.m.CI95'...
				obj.analyses.univariate.c.mode'...
				obj.analyses.univariate.c.CI95'...
				obj.analyses.univariate.alpha.mode'...
				obj.analyses.univariate.alpha.CI95'...
				obj.analyses.univariate.epsilon.mode'...
				obj.analyses.univariate.epsilon.CI95'],...
				'VariableNames',{'m_mode' 'm_CI5' 'm_CI95'...
				'c_mode' 'c_CI5' 'c_CI95'...
				'alpha_mode' 'alpha_CI5' 'alpha_CI95'...
				'epsilon_mode' 'epsilon_CI5' 'epsilon_CI95'},...
				'RowNames',data.participantFilenames)
			
			savename = ['parameterEstimates_' data.saveName '.txt'];
			writetable(participant_level, savename,...
				'Delimiter','\t')
			fprintf('The above table of participant-level parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end
		
		
	end
	
	
	
	methods (Access = protected)
		
		function obj = setInitialParamValues(obj, data)
			for n=1:obj.mcmcparams.nchains
				% Values for which there are just one of
				%obj.initial_param(n).groupW = rand/10; % group mean lapse rate
				
				%obj.initial_param(n).mprior = normrnd(-0.243,1);
				%obj.initial_param(n).cprior = normrnd(0,4);
				
				% One value for each participant
				for p=1:data.nParticipants
					obj.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.01));
					obj.initial_param(n).lr(p)		= rand/10;
					
					obj.initial_param(n).m(p) = normrnd(-0.243,1);
					obj.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end
		
		function [obj] = setObservedMonitoredValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			% group-level stuff
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
			
			obj.monitorparams = {'epsilon','epsilonprior',...
				'alpha','alphaprior',...
				'm','mprior',...
				'c','cprior'};%'participantlogk'};
		end
		
		function figParticipantLevelWRAPPER(obj, data)
			% PLOT INDIVIDUAL LEVEL STUFF HERE ----------
			for n=1:data.nParticipants
				fh = figure;
				fh.Name=['participant: ' num2str(n)];
				
				% get samples and data for this participant
				[samples] = obj.getParticipantSamples(n);
				[pData] = data.getParticipantData(n);

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				obj.figParticipant(samples, pData)
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				
				% EXPORTING ---------------------
				latex_fig(16, 18, 4)
				myExport(data.saveName, obj.modelType, ['-P' num2str(n)])
				% -------------------------------
				
				% close the figure to keep everything tidy
				close(fh)
			end
		end
		
		
		function [samples] = getParticipantSamples(obj,participant)
			% grabs samples just from one participant.
			% For the purposes of plotting data for 1 participant
			
			% 			names = fieldnames(obj.samples);
			% 			for n=1:numel(names)
			% 				if size(obj.samples.(names{n}),3)>1
			% 					temp = obj.samples.(names{n});
			% 					temp = temp(:,:,participant);
			% 					samples.(names{n}) = temp;
			% 				end
			% 			end
			
			fieldsToGet={'m','c','alpha','epsilon'};
			for n=1:numel(fieldsToGet)
				temp = obj.samples.(fieldsToGet{n});
				samples.(fieldsToGet{n}) = vec(temp(:,:,participant));
			end
			
		end
		
		
		function obj = doAnalysis(obj)
			% univariate summary stats
			fields ={'epsilon', 'alpha', 'm', 'c'};
			support={'positive', 'positive', [], []};
			% Do the analysis
			uni = univariateAnalysis(obj.samples, fields, support );
			% Store the results
			obj.analyses.univariate = uni;
			
% 			% #############################################################
% 			% as a complete botch set group parameters as blank
% 			obj.analyses.univariate.glM.mode	= NaN;
% 			obj.analyses.univariate.glM.CI95	= [NaN; NaN];
% 			obj.analyses.univariate.glC.mode	= NaN;
% 			obj.analyses.univariate.glC.CI95	= [NaN; NaN];
% 			
% 			obj.analyses.univariate.groupW.mode	= NaN;
% 			obj.analyses.univariate.groupW.CI95	= [NaN; NaN];
% 			% #############################################################
		end
		
	end
	
	
end

