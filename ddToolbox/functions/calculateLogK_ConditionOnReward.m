function [posteriorMean,lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag)
	lh=[];
	% -----------------------------------------------------------
	% log(k) = m * log(B) + c
	% k = exp( m * log(B) + c )
	%fh = @(x,params) exp( params(:,1) * log(x) + params(:,2));
	% a FAST vectorised version of above ------------------------
	fh = @(x,params) exp( bsxfun(@plus, ...
		bsxfun(@times,params(:,1),log(x)),...
		params(:,2)));
	% -----------------------------------------------------------

	myplot = mcmc.PosteriorPrediction1D(fh,...
		'xInterp',reward,...
		'samples',params,...
		'shouldPlotData',false);
	myplot.evaluateFunction([]);

	% Extract samples of P(k|reward)
	kSamples = myplot.Y;
	logKsamples = log(kSamples);

	% work out what xrange to examine over and add some padding
	[~,X] = hist(logKsamples);
	range = X(end)-X(1);
	Xpadded(1) = X(1) - range/2;
	Xpadded(2) = X(end) + range/2;
	xi = linspace(Xpadded(1), Xpadded(2), 1000);
	
	% Calculate kernel density estimate
	[f,xi] = ksdensity(logKsamples, xi, 'function', 'pdf');

	%posteriorMode = xi( argmax(f) );
	posteriorMean = mean(logKsamples);
	
	if plotFlag
		figure(1)
		lh = plot(xi,f);
		hold on
		drawnow
	end

end
