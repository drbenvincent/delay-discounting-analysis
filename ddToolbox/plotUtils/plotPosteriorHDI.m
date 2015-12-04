function plotPosteriorHDI(priorSamples, posteriorSamples)
	binsize = 0.05;
	% Now plot posterior distribution and examine HDI

	% priorSamples = obj.sampler.samples.glMprior(:);
	% posteriorSamples = obj.sampler.samples.glM(:);

	edges = [-5:binsize:2];
	% prior
	h = histogram(priorSamples, edges, 'Normalization','pdf');
	h.EdgeColor = 'none';
	h.FaceColor = [0.7 0.7 0.7];
	hold on

	% posterior
	h = histogram(posteriorSamples, edges, 'Normalization','pdf');
	h.EdgeColor = 'none';
	h.FaceColor = [0.2 0.2 0.2];

	%legend('prior','post', 'Location','NorthWest')
	%legend boxoff
	axis square
	box off
	axis tight, xlim([-2 1])
	removeYaxis()

	xlabel('G^m')
	title('Parameter estimation')

	showHDI(posteriorSamples)

	% 			opts.PlotBoxAspectRatio=[1 1 1];
	% 			opts.plotStyle = 'line';
	% 			opts.priorSamples = priorSamples;
	% 			opts.nbins = 1000;
	% 			subplot(1,2,2)
	% 			plotMCMCdist(posteriorSamples, opts);
	% 			title('b.')
	% 			xlabel('G^m')
	% 			xlim([-1.5 1])

	% TODO
	warning('REPLACE THIS FUNCTION WITH plotMCMCdist.m ???')

end
