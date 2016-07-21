function plotDiscountFunction(plotdata)

% TODO: This should be an indepedent function, provided as an input
discountFraction = @(k,D) bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, D) ) );

%% High level plot logic
plotFunction()
if ~isempty(plotdata.data.rawdata)
	%opts.maxlogB	= max( abs(p.Results.data.B) );
	maxD = max(plotdata.data.rawdata.DB);
	plotData();
else
	% base delay scale (x-axis) on median logk
	maxD = logk2halflife( median(plotdata.samples.posterior.logk) ) *2;
end
formatAxes()


	function plotData()
		hold on
		[x,y,z, markerCol,markerSize] = convertDataIntoMarkers(plotdata.data.rawdata);
		
		% plot
		for i=1:numel(x)
			h = plot(x(i), y(i),'o');
			h.Color='k';
			h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
			h.MarkerSize = markerSize(i)+4;
			hold on
		end
	end

	function formatAxes()
		axis tight
		xlabel('delay, $D^B$', 'interpreter','Latex')
		xlim([0 maxD*1.1])
		ylim([0 1])
		box off
	end

	function plotFunction()
		
		%% Calculate half-life
		logkDistribution = mcmc.UnivariateDistribution(plotdata.samples.posterior.logk,...
			'shouldPlot', false,...
			'pointEstimateType', plotdata.pointEstimateType);
		logkpointEstimate = logkDistribution.(plotdata.pointEstimateType);
		kPpointEstimate = exp(logkpointEstimate);
		halfLife = 1/kPpointEstimate;
		
		%% determine x-range
		if ~isempty(plotdata.data.rawdata)
			maxDelay = max( plotdata.data.rawdata.DB );
		else
			maxDelay = halfLife*100;
		end
		
		%% Do the plotting
		% 		switch p.Results.xScale
		% 			case{'linear'}
		D = linspace(0, maxDelay, 1000);
		
		% provide the point estimated calculated above (on logk) rather than k,
		% because of numerical problems.
		mcmc.PosteriorPrediction1D(discountFraction,...
			'xInterp',D,...
			'samples',exp(plotdata.samples.posterior.logk),...
			'ciType','examples',...
			'variableNames', {'delay', 'discount factor'},...
			'pointEstimateType', plotdata.pointEstimateType,...
			'pointEstimate',kPpointEstimate);
		
		% 			case{'log'}
		% 				error('')
		% 				D = logspace(-2,4,10000);
		% 				AB		= discountFraction(kPpointEstimate,D);
		% 				semilogx(D, AB);
	end

end
