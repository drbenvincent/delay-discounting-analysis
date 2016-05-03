function figParticipantME(pSamples, pointEstimateType, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('pSamples',@isstruct);
p.addRequired('pointEstimateType',@isstr);
p.addParameter('pData',[], @isstruct);
p.addParameter('opts',[], @isstruct);
p.parse(pSamples, pointEstimateType, varargin{:});


rows=1; cols=5;

subplot(rows, cols, 1)
epsilon_alpha = mcmc.BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType',p.Results.pointEstimateType);

subplot(rows, cols, 2)
plotPsychometricFunc(pSamples, p.Results.pointEstimateType);

subplot(rows, cols, 3)
m_c = mcmc.BivariateDistribution(pSamples.m(:), pSamples.c(:),...
	'xLabel','slope, $m$',...
	'ylabel','intercept, $c$',...
	'pointEstimateType',p.Results.pointEstimateType);

subplot(rows, cols, 4)
plotMagnitudeEffect(pSamples, p.Results.pointEstimateType);

% Plot in 3D data space
subplot(rows, cols, 5)
if ~isempty(p.Results.pData)
	% participant, we have data
	plotDiscountSurface(pSamples.m(:), pSamples.c(:),...
		p.Results.opts,...
		'data', p.Results.pData,...
		'pointEstimateType',p.Results.pointEstimateType);
else
	% no data for group level
	plotDiscountSurface(pSamples.m(:), pSamples.c(:),...
		p.Results.opts,...
		'pointEstimateType',p.Results.pointEstimateType);
end
% 			set(gca,'XTick',[10 100])
% 			set(gca,'XTickLabel',[10 100])
% 			set(gca,'XLim',[10 100])
end
