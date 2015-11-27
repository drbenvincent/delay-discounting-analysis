function plotMagnitudeEffect(samples, modeVals)
%
% log(k) = m * log(|B|) + c
% k = exp( m * log(|B|) + c )

% -----------------------------------------------------------
%fh = @(x,params) exp( params(:,1) * log(|x|) + params(:,2));
% a FAST vectorised version of above ------------------------
fh = @(x,params) exp( bsxfun(@plus, ...
	bsxfun(@times,params(:,1),log(abs(x))),...
	params(:,2)));
% -----------------------------------------------------------

x=logspace(0,4,50);

params(:,1) = samples.m(:);
params(:,2) = samples.c(:);

% Create myplot object (class = PosteriorPredictionPlot)
myplot = PosteriorPredictionPlot(fh, x, params);
myplot = myplot.plotCI([5 95]);
%myplot.plotExamples(100);
myplot.plotPointEstimate(modeVals);

%% Formatting
set(gca,'XScale','log')
set(gca,'YScale','log')
set(gca,'XTick',logspace(1,6,6))
set(gca,'YTick',logspace(-4,0,5))
forceNonExponentialTick
xlabel('reward','Interpreter','latex')
ylabel('$k$ (days$^{-1}$)','Interpreter','latex')
box off
axis square
return