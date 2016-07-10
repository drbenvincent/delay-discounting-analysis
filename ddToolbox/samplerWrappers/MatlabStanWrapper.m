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

			obj.modelFilename = modelFilename;
			%obj.sampler = 'STAN';
			%obj.setMCMCparams();
		end
		% =================================================================
		
% 		function setMCMCparams(obj)
% 			% Default parameters
% 			obj.mcmcparams.warmup = 100;
% 			obj.mcmcparams.iter = 5000;
% 			obj.mcmcparams.chains = 4;
% 			obj.mcmcparams.totalSamples = obj.mcmcparams.chains * obj.mcmcparams.iter;
% 		end
		

		function mcmcFitObject = conductInference(obj, model, data)
			%% preparation for MCMC sampling
			% Prepare data
			obj.setObservedValues(data);
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
				'data',obj.observed,...
				'warmup',500,...
				'iter',2000,...
				'chains',4,... 
				'verbose',true,...
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

		function setObservedValues(obj, data)
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

		function setStanHome(obj, stanHome)
			warning('TODO: validate this folder exists')
			obj.stanHome = stanHome;
		end


		function convergenceSummary(obj,saveFolder,IDnames)
		end

		function figUnivariateSummary(obj, participantIDlist, variables)
		end


		

	end

end
