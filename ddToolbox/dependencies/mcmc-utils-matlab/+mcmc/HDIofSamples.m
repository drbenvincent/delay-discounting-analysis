function [HDI] = HDIofSamples(samples, credibilityMass)
%
% [HDI] = HDIofSamples(samples, 0.95)
%
% Directly translated from code in:
% Kruschke, J. K. (2015). Doing Bayesian Data Analysis: A Tutorial with R,
% JAGS, and Stan. Academic Press.

assert(credibilityMass<1,'credibilityMass must be a <1')

samples = sort(samples(:));
ciIdxInc = floor( credibilityMass * numel( samples ) );
nCIs = numel( samples ) - ciIdxInc;

ciWidth=zeros(nCIs,1);
for n =1:nCIs
	ciWidth(n) = samples( n + ciIdxInc ) - samples(n);
end

[~, minInd] = min(ciWidth);
HDImin	= samples( minInd );
HDImax	= samples( minInd + ciIdxInc);
HDI		= [HDImin HDImax];
return
