function Z = calculateAUC(x,y, shouldPlot)
% Calculate the trapezoidal area under curve. NOTE: Normalized x-axis.

assert(isrow(x), 'x must be a row vector, ie [1, N]')
assert(size(y,2)==numel(x),'y must have same number of columns as x')

%% Add new column representing delay=0
nCols = size(y,1);
x = [0 x];
y = [ones(nCols,1) , y];

%% Normalise x
x = x ./ max(x);

%% Calculate trapezoidal AUC
Z = zeros(nCols,1);
for s=1:nCols
	Z(s) = trapz(x,y(s,:));
end

%% Plot
if shouldPlot
	histogram(Z, 'Normalization','probability',...
		'EdgeColor','none')
	set(gca,...
		'box','off')
	xlabel('Area Under Curve')
end
return
