% TODO: rename... this is for samples from UNIVARIATE distributions
function mode = calcMode(x)
% calculate the mode of a set of samples from some arbitrary univariate distribution.
assert(isvector(x))

% TODO: don't use Matlab's slow ksdensity
[F, XI] = ksdensity( x );
[~, ind] = max(F);
mode = XI(ind);
end
