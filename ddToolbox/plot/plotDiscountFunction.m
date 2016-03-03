function plotDiscountFunction(logk)
%
% plotDiscountSurface(-1, 10^-1);



k		= exp(logk);

%% Calculate discount fraction
%D = linspace(0,365*5,10000);
D = logspace(-2,365*4,10000);
AB		= 1 ./ (1 + k.*D); % discount fraction


plot(D, AB);


% formatting
axis tight
axis square
xlabel('delay', 'interpreter','latex')
ylabel('discount factor', 'interpreter','latex')
ylim([0 1])
return