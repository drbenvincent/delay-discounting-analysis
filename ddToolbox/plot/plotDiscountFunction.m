function plotDiscountFunction(logk)
%
% plotDiscountSurface(-1, 10^-1);

% CHOICE ~~~~~~~~~~
xScale = 'linear';
% ~~~~~~~~~~~~~~~~~

k = exp(logk);
halfLife = 1/k;

discountFraction = @(k,D) 1 ./ (1 + k.*D);

switch xScale
	case{'linear'}
		D = linspace(0, halfLife*100, 10000);
		AB		= discountFraction(k,D);
		plot(D, AB);
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

return