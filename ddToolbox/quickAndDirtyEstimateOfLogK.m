function [logk, kvec, prop_explained] = quickAndDirtyEstimateOfLogK(data)
% Given the response data for this participant, do a very quick and dirty
% estimate of the likely log discount rate (logk). This is used as initial
% parameters for the MCMC process.

%% 1-parameter hyperbolic discount function --------------------------------
% v = b ./ (1+(k*d)
% NOTE: This functions wants the discount rate (k), NOT the log(k)
V = @(d,k,b) bsxfun(@rdivide, b, 1+bsxfun(@times,k,d) );

%% vector of discount rates (k) to examine ---------------------------------
kvec = logspace(-8,2,1000);

%% Version 1 
% tic
% for n=1:length(kvec)
% 	k = kvec(n);
% 	
% 	% 1. Calculate present subjective value
% 	presentSubjectiveValue = V( data.D, k, data.B);
% 	
% 	% 2. Decide based upon a comparison of immediate reward
% 	chooseDelayed = (presentSubjectiveValue - data.A)>1;
% 	
% 	% how well can this account for actual responses
% 	err(n) = sum(abs(data.R - chooseDelayed));
% end
% toc

%% Version 2: vectorised
presentSubjectiveValue = V( data.DB, kvec, data.B);
chooseDelayed = bsxfun(@minus, presentSubjectiveValue, data.A) >1;
err = bsxfun(@minus, data.R, chooseDelayed);
err = sum(abs(err));

% calc proportion of responses explained
prop_explained = (data.trialsForThisParticant - err) / data.trialsForThisParticant;


%% Find the log(k) value with lowest error
% [~, index] = min(fliplr(err)); 
% k = kvec(numel(kvec)-index);
% logk = log(k);


[~, index] = max(prop_explained); 
k_optimal = kvec(index);
logk = log(k_optimal);

return