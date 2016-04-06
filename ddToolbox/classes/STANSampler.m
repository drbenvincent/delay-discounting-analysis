classdef STANSampler < Sampler
	%STANSampler
	
	properties (GetAccess = public, SetAccess = private)
		stanFit % object returned by STAN
		samples % struct of mcmc samples
		stanHome
	end
	
	methods (Access = public)
		
		% CONSTRUCTOR =====================================================
		function obj = STANSampler(modelFilename)
			obj = obj@Sampler();
			
			obj.modelFilename = modelFilename;
			obj.sampler = 'STAN';
			%obj.setMCMCparams();
		end
		% =================================================================
		
		function mcmcFitObject = conductInference(obj, model, data)
			% prepare data
			obj.setObservedValues(data);
			obj.convertObservedToLongform();
			
			stan_model = StanModel('file',obj.modelFilename);
			% Compile the Stan model. This takes a bit of time
			display('COMPILING STAN MODEL...')
			tic
			stan_model.compile();
			toc
			display('SAMPLING STAN MODEL...')
			tic
			obj.stanFit = stan_model.sampling(...
				'data',obj.observed,...
				'warmup',1000,...
				'iter',5000,...
				'chains',4,... %'algorithm','hmc',... {'NUTS','HMC'}, default = 'NUTS'
				'verbose',true,...
				'stan_home', obj.stanHome);
			obj.stanFit.block();
			toc
			
			% Attach the listener
			%addlistener(obj.stanFit,'exit',@stanExitHandler);
			%toc
			
			mcmcFitObject =  STANmcmc(obj.stanFit );
						
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
		
		
		function convertObservedToLongform(obj)
			% Stan does not support missing values or ragged arrays, so we are converting the observed data to long form.
			trialsPerParticipant = obj.observed.T;
			nParticipants = obj.observed.nParticipants;
			
			A=[];
			B=[];
			DA=[];
			DB=[];
			R=[];
			ID=[];
			
			row=1;
			for p = 1:nParticipants
				realTrialIndicies = [1:trialsPerParticipant(p)];
				rowIndecies = [row:row+trialsPerParticipant(p)-1];
				A(rowIndecies) = obj.observed.A(p,realTrialIndicies);
				B(rowIndecies) = obj.observed.B(p,realTrialIndicies);
				DA(rowIndecies) = obj.observed.DA(p,realTrialIndicies);
				DB(rowIndecies) = obj.observed.DB(p,realTrialIndicies);
				R(rowIndecies) = obj.observed.R(p,realTrialIndicies);
				ID(rowIndecies) = ones(1,trialsPerParticipant(p)).*p;
				row=row+trialsPerParticipant(p);
			end
			% overwrite
			obj.observed.A = A';
			obj.observed.B = B';
			obj.observed.DA = DA';
			obj.observed.DB = DB';
			obj.observed.R = R';
			obj.observed.ID = ID';
		end
		
		function setStanHome(obj, stanHome)
			obj.stanHome = stanHome;
		end
		
		
		
		% ==========================================================================
		% GET METHODS
		% ==========================================================================
		
		% function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
		% 	assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
		% 	% get all the samples for a given value of the 3rd dimension of
		% 	% samples. Dimensions are:
		% 	% 1. mcmc chain number
		% 	% 2. mcmc sample number
		% 	% 3. index of variable, meaning depends upon context of the
		% 	% model
		%
		% 	% % [flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
		% 	for i = 1:numel(fieldsToGet)
		% 	 	samples.(fieldsToGet{i}) = obj.samples.(fieldsToGet{i})(:,index);
		% 	 end
		% end
		%
		% function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
		% 	assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
		% 	[samples] = obj.getSamplesAtIndex(participant, fieldsToGet);
		% 	[samplesMatrix] = struct2Matrix(samples);
		% end
		%
		% function [samples] = getSamples(obj, fieldsToGet)
		% 	assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
		% 	samples = [];
		% 	for n=1:numel(fieldsToGet)
		% 	 	if isfield(obj.samples,fieldsToGet{n})
		% 	 		samples.(fieldsToGet{n}) = obj.samples.(fieldsToGet{n});
		% 	 	end
		% 	 end
		% end
		%
		% function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
		% 	[samples] = obj.getSamples(fieldsToGet);
		% 	[samplesMatrix] = struct2Matrix(samples);
		% end
		%
		% function [output] = getStats(obj, field, variable)
		% 	% % return column vector
		% 	% output = obj.stats.(field).(variable)';
		% 	output = 666; % TODO
		% end
		%
		% function [output] = getAllStats(obj)
		% 	% warning('Try to remove this method')
		% 	% output = obj.stats;
		% end
		%
		% function [predicted] = getParticipantPredictedResponses(obj, participant)
		% 	% % calculate the probability of choosing the delayed reward, for
		% 	% % all trials, for a particular participant.
		% 	% Rpostpred = obj.samples.Rpostpred;
		% 	% % extract samples from the participant
		% 	% Rpostpred = squeeze(Rpostpred(:,:,participant,:));
		% 	% % flatten over chains
		% 	% s = size(Rpostpred);
		% 	% participantRpostpredSamples = reshape(Rpostpred, s(1)*s(2), s(3));
		% 	% [nSamples,~] = size(participantRpostpredSamples);
		% 	% % predicted probability of choosing delayed (response = 1)
		% 	% predicted = sum(participantRpostpredSamples,1)./nSamples;
		% end
		
	end
	
end
