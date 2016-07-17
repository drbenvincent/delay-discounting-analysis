function plotDiscountFunction(logKsamples, varargin)

% TODO clean up this function

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('logKsamples',@isvector);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@isstruct);
p.addParameter('pointEstimateType','mean',@isstr);
p.parse(logKsamples, varargin{:});

% TODO: This should be an indepedent function, provided as an input
discountFraction = @(k,D) bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, D) ) );

% PLOT LOGIC
plotFunction(discountFraction, logKsamples, p)
if ~isempty(p.Results.data)
	%opts.maxlogB	= max( abs(p.Results.data.B) );
	opts.maxD		= max( p.Results.data.DB );
	plotData();
else
	% base delay scale (x-axis) on median logK
	opts.maxD = logk2halflife( median(logKsamples) ) *2;
end
formatAxes()

    function plotData()
        hold on
        [x,y,z, markerCol,markerSize] = convertDataIntoMarkers(p.Results.data);

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
        xlim([0 opts.maxD*1.1])
        ylim([0 1])
        box off
    end

end


function plotFunction(discountFraction, logKsamples, p)
%% Calculate half-life
logkDistribution = mcmc.UnivariateDistribution(logKsamples,...
	'shouldPlot',false,...
	'pointEstimateType',p.Results.pointEstimateType);
logKpointEstimate = logkDistribution.(p.Results.pointEstimateType);
kPpointEstimate = exp(logKpointEstimate);
halfLife = 1/kPpointEstimate;

%% determine x-range
if ~isempty(p.Results.data)
	maxDelay = max( p.Results.data.DB );
else
	maxDelay = halfLife*100;
end

%% Do the plotting
switch p.Results.xScale
	case{'linear'}
		D = linspace(0, maxDelay, 1000);

		% provide the point estimated calculated above (on logk) rather than k,
		% because of numerical problems.
		mcmc.PosteriorPrediction1D(discountFraction,...
			'xInterp',D,...
			'samples',exp(p.Results.logKsamples),...
			'ciType','examples',...
			'variableNames', {'delay', 'discount factor'},...
			'pointEstimateType',p.Results.pointEstimateType,...
			'pointEstimate',kPpointEstimate);

	case{'log'}
		error('')
		D = logspace(-2,4,10000);
		AB		= discountFraction(kPpointEstimate,D);
		semilogx(D, AB);
end

end
