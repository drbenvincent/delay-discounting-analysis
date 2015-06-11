function plotMagnitudeEffect(samples, modeVals)
%
% log(k) = m * log(B) + c
% k = exp( m * log(B) + c )

% -----------------------------------------------------------
%fh = @(x,params) exp( params(:,1) * log(x) + params(:,2));
% a FAST vectorised version of above ------------------------
fh = @(x,params) exp( bsxfun(@plus, ...
	bsxfun(@times,params(:,1),log(x)),...
	params(:,2)));
% -----------------------------------------------------------

x=logspace(0,4,50);

params(:,1) = samples.m(:);
params(:,2) = samples.c(:);

% Create myplot object (class = posteriorPredictionPlot)
myplot = posteriorPredictionPlot(fh, x, params);
myplot = myplot.plotCI([5 95]);
%myplot.plotExamples(20);
myplot.plotPointEstimate(modeVals)

%% Formatting

set(gca,'XScale','log')
set(gca,'YScale','log')

ylim([10^-4 10^1])

set(gca,'XTick',logspace(1,6,6))
set(gca,'YTick',logspace(-4,0,5))
forceNonExponentialTick

% add in dots for each B value actually tested -----
% hold on
% a=axis;
% loglog(expt.B, repmat(a(3),size(expt.B)), 'o-')

%  ---------------------------------------
xlabel('reward','Interpreter','latex')
ylabel('$k$ (days$^{-1}$)','Interpreter','latex')
%  ---------------------------------------
% %add_text_to_figure('TR','$\log(k) = m.\log(B)+c$', 12, 'latex')
% add_text_to_figure('TR',...
% 	sprintf('$$ \\log(k) = %2.2f\\log(B)+%2.2f $$',modeVals(1), modeVals(2) ),...
% 	12, 'latex')

box off

axis square



%myplot.plotPointEstimate(modeVals)







% x = exp(expt.logBInterp);
% [chains, nSamples, n] = size(samples.logkInterp);
% Y = reshape( samples.logkInterp, [chains*nSamples],n);
% % shuffle MCMC samples, helps plot more representative samples in the case
% % of high autocorrelation
% Y = Y(randperm(chains*nSamples),:);
% Y=exp(Y);
% % plotting ----------------------------------------
% loglog(x,Y([1:1000],:)',...
% 	'Color',[0.9, 0.9, 0.9],...
% 	'LineWidth',0.1)
% hold on
% loglog(x, median(Y))
% hold on
% CI = prctile(Y,[5 95]);
% loglog(x,CI,'k--')
% 
% xlim([10^0 10^4])
% ylim([10^-4 10^0])
% 
% set(gca,'XTick',logspace(1,6,6))
% set(gca,'YTick',logspace(-4,0,5))
% forceNonExponentialTick
% 
% % add in dots for each B value actually tested -----
% a=axis;
% loglog(expt.B, repmat(a(3),size(expt.B)), 'o-')
% 
% % formatting ---------------------------------------
% xlabel('$B$','Interpreter','latex')
% ylabel('$k$ (days$^{-1}$)','Interpreter','latex')
% add_text_to_figure('TR','$\log(k) = m.\log(B)+c$', 12, 'latex')
% box off
% 
% axis square
return