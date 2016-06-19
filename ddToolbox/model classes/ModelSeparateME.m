classdef ModelSeparateME < Model
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.

	properties (Access = protected)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelSeparateME(toolboxPath, sampler, data, saveFolder, varargin)
			% Because this class is a subclass of "Model" then we use
			% this next line to create an instance
			obj = obj@Model(data, saveFolder, varargin{:});

			switch sampler
				case{'JAGS'}
					modelPath = '/models/separateME.txt';
					obj.sampler = MatjagsWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
					obj.discountFuncType = 'me';
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantME;
			%obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperME;
			obj.plotFuncs.plotGroupLevel = @(x) []; % null function

			%% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'m_prior', 'c_prior','alpha_prior','epsilon_prior'};
			obj.varList.groupLevel = {};
			obj.varList.monitored = {'m', 'c','alpha','epsilon',...
				'm_prior', 'c_prior','alpha_prior','epsilon_prior',...
				'Rpostpred', 'P'};
		end
		% ================================================================

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

			nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).m = normrnd(-0.243,2, [nParticipants,1]);
				obj.initialParams(chain).c = normrnd(0,10, [nParticipants,1]);
				obj.initialParams(chain).alpha = abs(normrnd(0.01,10, [nParticipants,1]));
				obj.initialParams(chain).epsilon = 0.1 + rand([nParticipants,1])/10;

			end
		end

	end

end
