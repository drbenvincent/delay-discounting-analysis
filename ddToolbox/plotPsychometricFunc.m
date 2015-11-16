function plotPsychometricFunc(samples, modeVals)

% This is the psychometric function ---------------------------------------
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

params(:,1) = samples.epsilon(:);
params(:,2) = samples.alpha(:);

% Create myplot object (class = posteriorPredictionPlot)
myplot = posteriorPredictionPlot(fh, x, params);
myplot = myplot.plotCI([5 95]);
%myplot.plotProbMass(linspace(0,1,200))
%myplot.plotExamples(20);
myplot.plotPointEstimate(modeVals);

xlabel('$V^B-V^A$','Interpreter','latex')
ylabel('P(choose delayed)','Interpreter','latex')
axis square
return