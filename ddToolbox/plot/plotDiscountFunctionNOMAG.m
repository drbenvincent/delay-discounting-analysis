function plotDiscountFunctionNOMAG(logkSamples, data)

% convert logk to k --------
kSamples = exp(logkSamples);

% It is more accurate to calculate the model of logkSamples and convert
% that to k, as opposed to calculating the mode of k directly.
[modeVal] = calcUnivariateSummaryStats(logkSamples, []);
modeVal= exp(modeVal);

% This is the discount function ---------------------------------------
% NOTE: This functions wants the discount rate (k), NOT the log discount
% rate.
fh = @(x,k) 1 ./ (1+bsxfun(@times,k,x));
% -------------------------------------------------------------------------

D=linspace(0,max(data.D),200);

% Create myplot object (class = PosteriorPredictionPlot)
myplot = PosteriorPredictionPlot(fh, D, kSamples);
%myplot = myplot.plotCI([5 95]);
% %myplot.plotProbMass(linspace(0,1,200))
myplot.plotExamples(20);
% 
myplot.plotPointEstimate(modeVal);
% 
xlabel('delay $D$','Interpreter','latex')
ylabel('discount XXX','Interpreter','latex')
axis square


return