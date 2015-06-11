function bf = BayesFactor(priorSamples, postSamples, valueOfInterest, bandwidth)
% Calculate the Bayesian Factor of the two hypotheses described by the
% distributions priorSamples and postSamples (or rather samples which
% approximate those solutions). We calculate the density using kernel
% density estimation.
% This can be numerically a bit odd. I've found it necessary to compute the
% kernel density estimation at the SAME set of x values AND to use the same
% kernel bandwidth in order to get meaningful distributions that can be
% compared.
% The kernel density estimate is then used to calculat the density at the
% exact x-value of interest using interpolation.


% ensure samples provided are in the form of a vector
priorSamples= priorSamples(:);
postSamples = postSamples(:);

%% calculate kernel density estimation

xmin = min([priorSamples ;postSamples]);
xmax = max([priorSamples ;postSamples]);
N = 10^5;

xi = linspace(xmin, xmax, N);
%bandwidth = 0.2;

[priorDensity, ~, priorDensityAtValue] = ...
	calcDensity(priorSamples, xi, bandwidth, valueOfInterest);

[postDensity, ~, postDensityAtValue] = ...
	calcDensity(postSamples, xi, bandwidth, valueOfInterest);


%% Calculate Bayes Factor
bf = postDensityAtValue ./ priorDensityAtValue;


%% plot
hold off
hprior=plot(xi, priorDensity, 'k--');
hold on
hpost=plot(xi, postDensity, 'k-');

plot(valueOfInterest, priorDensityAtValue, 'ko')
plot(valueOfInterest, postDensityAtValue, 'ko',...
	'MarkerFaceColor','k');


legend([hprior, hpost], 'prior','posterior')
xlim([-0.5 0.5])
box off

str = sprintf('BF = %.1f',bf);
add_text_to_figure('TL',str, 15)

end



function [density, xi, DensityAtValueOfInterest] = calcDensity(samples, xi, bandwidth, valueOfInterest)
% kernel density estimate
[density,xi]	= ksdensity(samples, xi, 'width',bandwidth);
% normalise
density = density ./ sum(density);

% calcalate density at value of interest
DensityAtValueOfInterest = interp1(xi, density, valueOfInterest);
end 