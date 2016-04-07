function  HT_BayesFactor(priorSamples, posteriorSamples)
	warning('IS THERE A MATLAB BAYES FACTOR PACKAGE FOR MCMC SAMPLES?')
	binsize = 0.05;
	% extract samples
% 	priorSamples = obj.sampler.samples.glMprior(:);
% 	posteriorSamples = obj.sampler.samples.glM(:);
% 	priorSamples = obj.sampler.getSamplesAsMatrix({'m_group_prior'});
% 	posteriorSamples = obj.sampler.getSamplesAsMatrix({'m_group'});

	% in order to evaluate the order-restricted hypothesis m<0, then we need to
	% remove samples where either prior or posterior contain samples
	priorSamples = priorSamples(priorSamples<0);
	posteriorSamples = posteriorSamples(posteriorSamples<0);

	% 			% calculate the density at m=0, using kernel density estimation
	% 			MMIN = min([priorSamples; posteriorSamples])*1.1;
	% 			[bandwidth,priordensity,xmesh,cdf]=kde(priorSamples,500,MMIN,0);
	% 			trapz(xmesh,priordensity) % check the area is 1
	% 			[bandwidth,postdensity,xmesh,cdf]=kde(posteriorSamples,500,MMIN,0);
	% 			trapz(xmesh,postdensity) % check the area is 1
	%
	% 			%priordensity = priordensity./sum(priordensity);
	% 			%postdensity = postdensity./sum(postdensity);
	% 			% calculate log bayes factor
	% 			BF_01 =  priordensity(xmesh==0) / postdensity(xmesh==0) ;
	% 			BF_10 =  postdensity(xmesh==0) / priordensity(xmesh==0) ;


	edges = [-5:binsize:0];
	% 			% First plot
	% 			histogram(priorSamples, edges, 'Normalization','pdf', 'DisplayStyle','stairs')
	% 			hold on
	% 			histogram(posteriorSamples, edges, 'Normalization','pdf', 'DisplayStyle','stairs')
	% Grab the actual density
	[Nprior,~] = histcounts(priorSamples, edges, 'Normalization','pdf');
	[Npost,~] = histcounts(posteriorSamples, edges, 'Normalization','pdf');
	% grab density at zero
	postDensityAtZero	= Npost(end);
	priorDensityAtZero	= Nprior(end);
	% Calculate Bayes Factor

	BF_10 = postDensityAtZero / priorDensityAtZero
	BF_01 = priorDensityAtZero / postDensityAtZero


	% plot
	figure
	subplot(1,2,1)
	%plot(xmesh,priordensity,'k--')
	h = histogram(priorSamples, edges, 'Normalization','pdf');
	h.EdgeColor = 'none';
	h.FaceColor = [0.7 0.7 0.7];
	hold on
	%plot(xmesh,postdensity,'k-')
	h = histogram(posteriorSamples, edges, 'Normalization','pdf');
	h.EdgeColor = 'none';
	h.FaceColor = [0.2 0.2 0.2];
	% plot density at x=0
	plot(0, priorDensityAtZero,'ko','MarkerFaceColor','w')
	plot(0, postDensityAtZero,'ko','MarkerFaceColor','k')
	%legend('prior','post', 'Location','NorthWest')
	%legend boxoff
	axis square
	box off
	axis tight, xlim([-2 0])
	removeYaxis()
	%addTextToFigure('TR',...
	%	sprintf('log BF_{10} = %2.2f',log(BF_10)),...
	%	15,	'latex')
	%ylabel('density')
	xlabel('G^m')
	title('Bayesian hypothesis testing')
end
