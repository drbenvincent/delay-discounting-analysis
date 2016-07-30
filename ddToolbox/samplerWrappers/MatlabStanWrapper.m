classdef MatlabStanWrapper < SamplerWrapper
	%MatlabStanWrapper

	properties (GetAccess = public, SetAccess = private)
		stanFit % object returned by STAN
		samples % struct of mcmc samples
		stanHome
	end

	methods (Access = public)

		function obj = MatlabStanWrapper(modelFilename)
			obj = obj@SamplerWrapper();
			obj.stanHome = '~/cmdstan-2.11.0';
			obj.modelFilename = modelFilename;
			obj = obj.setDefaultMCMCparams();
		end


		function mcmcFitObject = conductInference(obj, model)

            %% sampler-specific preparation
			obj.observed = obj.addStanSpecificObservedData(model.observedData, model.data);
			stan_model = StanModel('file',obj.modelFilename,...
				'stan_home', obj.stanHome);
			display('COMPILING STAN MODEL...')
			tic
			stan_model.compile();
			toc

			%% Get our sampler to sample
			display('SAMPLING STAN MODEL...')
			tic
			obj.stanFit = stan_model.sampling(...
				'data', obj.observed,...
				'warmup', obj.mcmcparams.nburnin,...	% warmup = burn-in
				'iter', obj.samplesPerChain(),...		% iter = number of MCMC samples
				'chains', obj.mcmcparams.nchains,...
				'verbose', true,...
				'stan_home', obj.stanHome);
			% block command window access until sampling finished
			obj.stanFit.block();
			toc

			% Create an MCMC object. This is basically a wrapper around the
			% StanFit object which has useful getter functions. It also
			% calculates stats about samples
			mcmcFitObject =  STANmcmc(obj.stanFit);

            % Uncomment this line if you want auditory feedback
			%speak('sampling complete')
		end

		%% SET METHODS ----------------------------------------------------
		function obj = setDefaultMCMCparams(obj)
			obj.mcmcparams.nburnin		= 1000;	% (warmup)
			obj.mcmcparams.nsamples		= 10^4;	% represents TOTAL number of samples we want
			obj.mcmcparams.nchains		= 2;
		end

		function obj = setStanHome(obj, stanHome)
			warning('TODO: validate this folder exists')
			obj.stanHome = stanHome;
		end

	end

	methods (Static)
		function observedData = addStanSpecificObservedData(observedData, data)
			observedData.nParticipants	= max(observedData.participantIndexList);
			observedData.totalTrials	= data.totalTrials;
		end
	end

end
