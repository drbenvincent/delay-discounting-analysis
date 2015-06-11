function [HDI] = HDIofSamples(samples, credibilityMass)
%
% [HDI] = HDIofSamples(samples, 0.95)
%
% Directly translated from code in:
% Kruschke, J. K. (2015). Doing Bayesian Data Analysis: A Tutorial with R, 
% JAGS, and Stan. Academic Press.

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

%     HDImin = sortedPts[ which.min( ciWidth ) ]
%     HDImax = sortedPts[ which.min( ciWidth ) + ciIdxInc ]
%     HDIlim = c( HDImin , HDImax )

% HDIofMCMC = function( sampleVec , credMass=0.95 ) {
%     # Computes highest density interval from a sample of representative values,
%     #   estimated as shortest credible interval.
%     # Arguments:
%     #   sampleVec
%     #     is a vector of representative values from a probability distribution.
%     #   credMass
%     #     is a scalar between 0 and 1, indicating the mass within the credible
%     #     interval that is to be estimated.
%     # Value:
%     #   HDIlim is a vector containing the limits of the HDI
%     sortedPts = sort( sampleVec )
%     ciIdxInc = floor( credMass * length( sortedPts ) )
%     nCIs = length( sortedPts ) - ciIdxInc
%     ciWidth = rep( 0 , nCIs )
%     for ( i in 1:nCIs ) {
%         ciWidth[ i ] = sortedPts[ i + ciIdxInc ] - sortedPts[ i ]
%     }
%     HDImin = sortedPts[ which.min( ciWidth ) ]
%     HDImax = sortedPts[ which.min( ciWidth ) + ciIdxInc ]
%     HDIlim = c( HDImin , HDImax )
%     return( HDIlim )
% }