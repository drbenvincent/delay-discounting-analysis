function plotDiscountFunction(plotdata)


% checks
if isempty(plotdata.samples.posterior.logk)...
		|| any(isnan(plotdata.samples.posterior.logk(:)))
	warning('invalid or no logk samples provided')
	return
end

%% High level plot logic

% Plot the discount function, regardless
plotFunction()

% We need to decide what kind of data plotting we are doing, based upon
% whether we have front-end delays or not, etc.
	
if ~isempty(plotdata.data.rawdata)
	%opts.maxlogB	= max( abs(p.Results.data.B) );
	maxD = max(plotdata.data.rawdata.DB);
else
	% base delay scale (x-axis) on median logk
	maxD = logk2halflife( median(plotdata.samples.posterior.logk) ) *2;
end

if ~front_end_delays_present()
	plotData();
else
	% front-end delays present, so don't plot data
end

formatAxes()


	function truefalse = front_end_delays_present()
		truefalse = any(plotdata.data.rawdata.DA>0);
	end

	function plotData()
		hold on
		[x,y,z, markerCol,markerSize] = convertDataIntoMarkers(plotdata.data.rawdata);
		
		% plot
		for i=1:numel(x)
			h = plot(y(i), z(i),'o');
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
		mcmc.PosteriorPrediction1D(@discountFraction_Hyperbolic1,... %<-------- pass function in as a parameter?
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


function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers(data)
% find unique experimental designs
D=[abs(data.A), abs(data.B), data.DA, data.DB];
[C, ia, ic] = unique(D,'rows');
% loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset=ic==n;
	% markerSize = number of times this design has been run
	markerSize(n) = sum(myset);
	% Colour = proportion of times participant chose immediate for that design
	markerCol(n) = sum(data.R(myset)==0) ./ markerSize(n);
	
	x(n) = abs(data.B( ia(n) )); % £B
	y(n) = data.DB( ia(n) ); % delay to get £B
	z(n) = abs(data.A( ia(n) )) ./ abs(data.B( ia(n) ));
end
end