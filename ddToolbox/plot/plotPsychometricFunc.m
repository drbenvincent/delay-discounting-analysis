function plotPsychometricFunc(epsilonSamples, alphaSamples, modeVals)
% This is the Psychometric function ---------------------------------------
%fh = @(x,params) params(:,1) + (1-2*params(:,1)) * normcdf( (x ./ params(:,2)) , 0, 1);
%fh = @FAST_PSYCHOMETRIC;
% This is converted to work FAST ------------------------------------------
%display('**** SPEED THIS CODE UP ****')
fh = @(x,params) bsxfun(@plus,...
	params(:,1),...
	bsxfun(@times, ...
	(1-2*params(:,1)),...
	normcdf( bsxfun(@rdivide, x, params(:,2) ) , 0, 1)) );
% -------------------------------------------------------------------------

% Determine the x range to plot over
x=linspace(-200,200,200);

params(:,1) = epsilonSamples(:);
params(:,2) = alphaSamples(:);

% Create myplot object (class = PosteriorPredictionPlot)
myplot = PosteriorPredictionPlot(fh, x, params);
%myplot = myplot.plotCI([5 95]);
%myplot.plotProbMass(linspace(0,1,100))
myplot.plotExamples(100);
myplot.plotPointEstimate(modeVals);

xlabel('$V^B-V^A$','Interpreter','latex')
ylabel('P(choose delayed)','Interpreter','latex')
axis square
return