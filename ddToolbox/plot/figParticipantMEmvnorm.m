function figParticipantMEmvnorm(plotdata)

fh = figure;
fh.Name = ['participant: ' plotdata.IDname];
rows = 1; 
cols = 5;

subplot(rows, cols, 1)
epsilon_alpha = mcmc.BivariateDistribution(plotdata.samples.posterior.epsilon(:), plotdata.samples.posterior.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType',plotdata.pointEstimateType);

subplot(rows, cols, 2)
plotPsychometricFunc(plotdata.samples, plotdata.pointEstimateType);

subplot(rows, cols, 3)
m_c = mcmc.BivariateDistribution(plotdata.samples.posterior.mc(:,:,1), plotdata.samples.posterior.mc(:,:,2),...
	'xLabel','slope, $m$',...
	'ylabel','intercept, $c$',...
	'pointEstimateType',plotdata.pointEstimateType);

subplot(rows, cols, 4)
%plotMagnitudeEffect(plotdata.samples, plotdata.pointEstimateType);

% Plot in 3D data space
subplot(rows, cols, 5)
%plotDiscountSurface(plotdata);

latex_fig(16, 18, 4)
myExport('fig',...
	'saveFolder', plotdata.saveFolder,...
	'prefix', plotdata.IDname,...
	'suffix', plotdata.modelType);

close(fh)

	function goodnessStr = makeGoodnessStr()
		percentPredicted = plotdata.postPred.percentPredictedDistribution(:);
		pp = mcmc.UnivariateDistribution(percentPredicted, 'shouldPlot', false);
		goodnessStr = sprintf('%% predicted: %3.1f (%3.1f - %3.1f)',...
			pp.(plotdata.pointEstimateType)*100,...
			pp.HDI(1)*100,...
			pp.HDI(2)*100);
		
	end

end