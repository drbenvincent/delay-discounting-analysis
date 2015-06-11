function [logk, kvec, err] = quickAndDirtyEstimateOfLogK(data)
% Given the response data for this participant, do a very quick and dirty
% estimate of the likely log discount rate (logk). This is used as initial
% parameters for the MCMC process.

% This is the discount function ---------------------------------------
% NOTE: This functions wants the discount rate (k), NOT the log discount
% rate.
%V = @(d,k,b) b ./ (1+bsxfun(@times,k,d));

V = @(d,k,b) bsxfun(@rdivide, b, 1+bsxfun(@times,k,d) );

% -------------------------------------------------------------------------

kvec=logspace(-8,2,1000);


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


%%

%[a b]=min((err)); k = kvec(b);
[a b]=min(fliplr(err)); k = kvec(numel(kvec)-b);

% semilogx(kvec, err)
% vline(k);


logk=log(k);


return