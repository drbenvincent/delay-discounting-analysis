function plotDiscountFunction(logK, logKsamples, varargin)

% TODO clean up this function

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('logK',@isscalar);
p.addRequired('logKsamples',@isvector);
p.addParameter('xScale','linear',@isstr);
p.addParameter('data',[],@isstruct)
p.parse(logK, logKsamples, varargin{:});

k = exp(p.Results.logK);
halfLife = 1/k;

discountFraction = @(k,D) bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, D) ) );

switch p.Results.xScale
	case{'linear'}
		D = linspace(0, halfLife*100, 1000);

		myplot = PosteriorPredictionPlot(discountFraction, D, exp(p.Results.logKsamples) );
		myplot.plotExamples(100);
		myplot.plotPointEstimate( exp(logK) );

	case{'log'}
		D = logspace(-2,4,10000);
		AB		= discountFraction(k,D);
		semilogx(D, AB);
end

% formatting
axis tight
axis square
box off
xlabel('delay', 'interpreter','latex')
ylabel('discount factor', 'interpreter','latex')
ylim([0 1])

% default scale the x axis from 0 to a multiple of the half life
xlim([0 halfLife*5])


% if we have data
if ~isempty(p.Results.data)
	hold on
	opts.maxlogB	= max( abs(p.Results.data.B) );
	opts.maxD		= max( p.Results.data.DB );

	% find unique experimental designs
	D=[abs(p.Results.data.A), abs(p.Results.data.B), p.Results.data.DA, p.Results.data.DB];
	[C, ia, ic] = unique(D,'rows');
	%loop over unique designs (ic)
	for n=1:max(ic)
		% binary set of which trials this design was used on
		myset=ic==n;
		% Size = number of times this design has been run
		F(n) = sum(myset);
		% Colour = proportion of times that participant chose immediate
		% for that design
		COL(n) = sum(p.Results.data.R(myset)==0) ./ F(n);

		%x(n) = abs(p.Results.data.B( ia(n) )); % £B
		x(n) = p.Results.data.DB( ia(n) ); % delay to get £B
		y(n) = abs(p.Results.data.A( ia(n) )) ./ abs(p.Results.data.B( ia(n) ));
	end

	% plot
	for i=1:max(ic)
		h = plot(x(i), y(i),'o');
		h.Color='k';
		h.MarkerFaceColor=[1 1 1] .* (1-COL(i));
		h.MarkerSize = F(i)+4;
		hold on
	end

	xlabel('delay, $D^B$', 'interpreter','Latex')
	%ylabel('$|A|/|B|$', 'interpreter','Latex')

	xlim([0 opts.maxD*1.1])
	ylim([0 1])
	box off

end

return
