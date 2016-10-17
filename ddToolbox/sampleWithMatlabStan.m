function codaObject = sampleWithMatlabStan(...
	modelFilename, observedData, mcmcparams, ~, ~)

assert(ischar(modelFilename))
assert(isstruct(observedData))
assert(isstruct(mcmcparams))

%% sampler-specific preparation ++++++++++++++++++++
% NOTE: mstan.stan_home() function defined in the repo 'MatlabStan' which was
% downloaded to your default matlab directory. This is findable by typing:
% >> getenv('HOME')
stan_model = StanModel('file', modelFilename,...
	'stan_home', mstan.stan_home());
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
	'stan_home', mstan.stan_home() );
% block command window access until sampling finished
obj.stanFit.block();
toc

% Uncomment this line if you want auditory feedback
%speak('sampling complete')

codaObject = CODA.buildFromStanFit(obj.stanFit);

end