classdef MatlabStanWrapper < SamplerWrapper
	%MatlabStanWrapper

	properties (GetAccess = public, SetAccess = private)
		stanFit % object returned by STAN
		samples % struct of mcmc samples
		stanHome
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = MatlabStanWrapper(modelFilename)
			obj = obj@SamplerWrapper();

			obj.stanHome = '~/cmdstan-2.9.0';
			
			obj.modelFilename = modelFilename;
			obj = obj.setMCMCparams();
		end
		% =================================================================
		
		function obj = setMCMCparams(obj)
			% Default parameters
			obj.mcmcparams.warmup = 1000;
			obj.mcmcparams.iter = 10^4;
			obj.mcmcparams.chains = 2;
			obj.mcmcparams.totalSamples = obj.mcmcparams.chains * obj.mcmcparams.iter;
		end
		
		function mcmcFitObject = conductInference(obj, model, data)
			%% preparation for MCMC sampling
			% Prepare data
			obj = obj.setObservedValues(data);
			% create Stan Model
			stan_model = StanModel('file',obj.modelFilename,...
				'stan_home', obj.stanHome);
			% Compile the Stan model. This takes a bit of time
			display('COMPILING STAN MODEL...')
			tic
			stan_model.compile();
			toc
			% Do sampling
			display('SAMPLING STAN MODEL...')
			tic
			obj.stanFit = stan_model.sampling(...
				'data', obj.observed,...
				'warmup', obj.mcmcparams.warmup,...
				'iter', obj.mcmcparams.iter,...
				'chains', obj.mcmcparams.chains,... 
				'verbose', true,...
				'stan_home', obj.stanHome);
			% block command window access until sampling finished
			obj.stanFit.block(); 
			toc

			% Attach the listener
			%addlistener(obj.stanFit,'exit',@stanExitHandler);
			%toc

			% Create an MCMC object. This is basically a wrapper around the
			% StanFit object which has useful getter functions. It also
			% calculates stats about samples
			mcmcFitObject =  STANmcmc(obj.stanFit);
						
			
			% % grab all samples into a structure
			% obj.samples = obj.stanFit.extract('permuted',true);
			% %obj.samples = obj.stanFit.extract('permuted',false); % chains separate
			%
			% % display('***** SAVE THE MODEL OBJECT HERE *****')
		end

		function obj = setObservedValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
		end


% 		function convertObservedToLongform(obj)
% 			% Stan does not support missing values or ragged arrays, so we are converting the observed data to long form.
% 			trialsPerParticipant = obj.observed.T;
% 			nParticipants = obj.observed.nParticipants;
% 
% 			A=[];
% 			B=[];
% 			DA=[];
% 			DB=[];
% 			R=[];
% 			ID=[];
% 
% 			row=1;
% 			for p = 1:nParticipants
% 				realTrialIndicies = [1:trialsPerParticipant(p)];
% 				rowIndecies = [row:row+trialsPerParticipant(p)-1];
% 				A(rowIndecies) = obj.observed.A(p,realTrialIndicies);
% 				B(rowIndecies) = obj.observed.B(p,realTrialIndicies);
% 				DA(rowIndecies) = obj.observed.DA(p,realTrialIndicies);
% 				DB(rowIndecies) = obj.observed.DB(p,realTrialIndicies);
% 				R(rowIndecies) = obj.observed.R(p,realTrialIndicies);
% 				ID(rowIndecies) = ones(1,trialsPerParticipant(p)).*p;
% 				row=row+trialsPerParticipant(p);
% 			end
% 			% overwrite
% 			obj.observed.A = A';
% 			obj.observed.B = B';
% 			obj.observed.DA = DA';
% 			obj.observed.DB = DB';
% 			obj.observed.R = R';
% 			obj.observed.ID = ID';
% 		end

		function obj = setStanHome(obj, stanHome)
			warning('TODO: validate this folder exists')
			obj.stanHome = stanHome;
		end
		
		function convergenceSummary(obj,saveFolder,IDnames)
		end

		function figUnivariateSummary(obj, participantIDlist, variables)
		end

	end

end
