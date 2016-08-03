function codaObject = sampleWithMatlabStan(...
	modelFilename, observedData, mcmcparams, ~, ~)


stan_home = '~/cmdstan-2.11.0';

%% sampler-specific preparation ++++++++++++++++++++
stan_model = StanModel('file', modelFilename,...
	'stan_home', stan_home);
display('COMPILING STAN MODEL...')
tic
stan_model.compile();
toc
% ++++++++++++++++++++++++++++++++++++++++++++++++++

%% Get our sampler to sample
display('SAMPLING STAN MODEL...')
tic
obj.stanFit = stan_model.sampling(...
	'data', observedData,...
	'warmup', mcmcparams.nburnin,...	% warmup = burn-in
	'iter', ceil( mcmcparams.nsamples / mcmcparams.nchains),...		% iter = number of MCMC samples
	'chains', mcmcparams.nchains,...
	'verbose', true,...
	'stan_home', stan_home);
% block command window access until sampling finished
obj.stanFit.block();
toc

% Uncomment this line if you want auditory feedback
%speak('sampling complete')

codaObject = CODA.buildFromStanFit(obj.stanFit);

end