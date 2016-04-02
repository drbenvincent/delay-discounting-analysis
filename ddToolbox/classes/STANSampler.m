classdef STANSampler < Sampler
%STANSampler

properties (GetAccess = public, SetAccess = private)
stanFit % object returned by STAN
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

function conductInference(obj)

	% puts observed data into sampler.obeserved
	obj.modelHandle.setObservedValues(); % code smell, too intimate

	obj.convertObservedToLongform();



	model = StanModel('file',obj.modelFilename);
	% Compile the Stan model. This takes a bit of time
	display('COMPILING STAN MODEL...')
	model.compile();
	display('SAMPLING STAN MODEL...')
	obj.stanFit = model.sampling(...
		'data',obj.observed,...
		'warmup',100,...
		'iter',500,...
		'chains',2,...
		'verbose',false);
	% Attach the listener
	addlistener(obj.stanFit,'exit',@stanExitHandler);


	% obj.stanFit = stan('file',obj.modelFilename,...
	% 'data',obj.observed,...
	% 'iter',500,...
	% 'chains',2,...
	% 'verbose',true);

	%obj.stanFit.print();

	% display('***** SAVE THE MODEL OBJECT HERE *****')
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
	obj.observed.A = A;
	obj.observed.B = B;
	obj.observed.DA = DA;
	obj.observed.DB = DB;
	obj.observed.R = R;
	obj.observed.ID = ID;
end

function convergenceSummary(obj)
	% save to a text file
end

% ==========================================================================
% GET METHODS
% ==========================================================================

function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
	% assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
	% % get all the samples for a given value of the 3rd dimension of
	% % samples. Dimensions are:
	% % 1. mcmc chain number
	% % 2. mcmc sample number
	% % 3. index of variable, meaning depends upon context of the
	% % model
	%
	% [flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
	% for i = 1:numel(fieldsToGet)
	% 	samples.(fieldsToGet{i}) = flatSamples.(fieldsToGet{i})(:,index);
	% end
end

function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
	% assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
	% % TODO: This function is doing the same thing as getSamplesAtIndex() ???
	%
	% for n=1:numel(fieldsToGet)
	% 	samples.(fieldsToGet{n}) = vec(obj.samples.(fieldsToGet{n})(:,:,participant));
	% end
	%
	% [samplesMatrix] = struct2Matrix(samples);
end

function [samples] = getSamples(obj, fieldsToGet)
	% % This will not flatten across chains
	% assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
	% samples = [];
	% for n=1:numel(fieldsToGet)
	% 	if isfield(obj.samples,fieldsToGet{n})
	% 		samples.(fieldsToGet{n}) = obj.samples.(fieldsToGet{n});
	% 	end
	% end
end

function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
	%
	% [samples] = obj.getSamples(fieldsToGet);
	%
	% % flatten across chains
	% fields = fieldnames(samples);
	% for n=1:numel(fields)
	% 	samples.(fields{n}) = vec(samples.(fields{n}));
	% end
	%
	% [samplesMatrix] = struct2Matrix(samples);
end

function [samples] = getAllSamples(obj)
	% warning('Try to remove this method')
	% samples = obj.samples;
end

function [output] = getStats(obj, field, variable)
	% % return column vector
	% output = obj.stats.(field).(variable)';
end

function [output] = getAllStats(obj)
	% warning('Try to remove this method')
	% output = obj.stats;
end

function [predicted] = getParticipantPredictedResponses(obj, participant)
	% % calculate the probability of choosing the delayed reward, for
	% % all trials, for a particular participant.
	% Rpostpred = obj.samples.Rpostpred;
	% % extract samples from the participant
	% Rpostpred = squeeze(Rpostpred(:,:,participant,:));
	% % flatten over chains
	% s = size(Rpostpred);
	% participantRpostpredSamples = reshape(Rpostpred, s(1)*s(2), s(3));
	% [nSamples,~] = size(participantRpostpredSamples);
	% % predicted probability of choosing delayed (response = 1)
	% predicted = sum(participantRpostpredSamples,1)./nSamples;
end

end

end
