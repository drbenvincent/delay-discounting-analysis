% demo

try
	pathOfPackage = '~/git-local/mcmc-utils-matlab';
	addpath(pathOfPackage)
catch
	error('Set ''pathToPackage'' to parent of the +mcmc package')
end

mcmc.setPlotTheme('fontsize',16, 'linewidth',2)



%% generate faux mcmc data
mu = [1 -1 0];
Sigma = [1 .4 .8;.4 1 .3;.8 .3 1];
samples = mvnrnd(mu, Sigma, 10^5);
%plot(samples(:,1),samples(:,2),'.');
variableNames={'retroflux units, $\rho$',...
	'awesomeness, $\alpha$',...
	'undulation, $\mu$'};



%% univariate distribution
figure(1), clf
subplot(1,2,1)
uni = mcmc.UnivariateDistribution(samples(:,1),...
	'xLabel', variableNames{1});
title('plotstyle=''density''')

subplot(1,2,2)
uni2 = mcmc.UnivariateDistribution(samples(:,2),...
	'xLabel', variableNames{2},...
	'plotStyle','hist');
title('plotstyle=''hist''')



%% bivariate distribution
figure(2), clf
subplot(1,3,1)
bi1 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2});
title('plotstyle=''density''')

subplot(1,3,2)
bi2 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2},...
	'plotStyle','hist');
title('plotstyle=''hist''')
tempAxisLims = axis;

subplot(1,3,3)
bi3 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2},...
	'plotStyle','contour',...
	'probMass',0.5);
title('plotstyle=''contour''')
axis(tempAxisLims)

%% Triplot / Corner plot
% For 2 parameters or more, a corner plot is useful to look at all the
% univariate and all combinations of bivariate marginal distributions.
figure(3), clf
tri = mcmc.TriPlotSamples(samples,...
	variableNames,...
	'figSize', 20);


%% PosteriorPrediction1D

% example function y=mx+c
%fh = @(x,params) params(:,1).*x + params(:,2);
fh = @(x,params) bsxfun(@plus, bsxfun(@times,params(:,1), x), params(:,2));



% Generate faux MCMC samples
nSamples=10^5;
chocolate=randn([nSamples 1])+20;	% intercept
happines=randn([nSamples 1])+2;	% slope
samples=[happines chocolate]; % samples is of size [nSamples x nParams]
variableNames={'chocolate',...
	'happines, $\Omega$'};

% Generate faux x,y data
xdata=linspace(-5,20,5);
ydata=fh(xdata,[2 20]) + randn(size(xdata))*5;

% finally, create the object
figure(4), clf
subplot(1,3,1)
pp1 = mcmc.PosteriorPrediction1D(fh,...
	'xInterp',linspace(-5,20,400),...
	'samples',samples,...
	'xData',xdata,...
	'yData',ydata,...
	'ciType','examples',...
	'variableNames', variableNames);
title('ciType=''examples''')

subplot(1,3,2)
pp2 = mcmc.PosteriorPrediction1D(fh,...
	'xInterp',linspace(-5,20,400),...
	'samples',samples,...
	'xData',xdata,...
	'yData',ydata,...
	'ciType','range',...
	'variableNames', variableNames);
title('ciType=''range''')

subplot(1,3,3)
pp3 = mcmc.PosteriorPrediction1D(fh,...
	'xInterp',linspace(-5,20,400),...
	'samples',samples,...
	'xData',xdata,...
	'yData',ydata,...
	'ciType','probMass',...
	'variableNames', variableNames);
title('ciType=''probMass''')







%% CODE BELOW IS UNDER DEVELOPMENT ========================================


% %% mcmc container (a subpackage)
% % We will have a variety of mcmc containers which will provide helpful
% % functions.
% import('mcmc.container.*')
%
% % JAGS
% jagsMcmcObject = JAGSmcmc(samples, stats, mcmcparams);
%
% % just a set of samples
% simpleMcmcObject = SimpleMcmc(samples);
