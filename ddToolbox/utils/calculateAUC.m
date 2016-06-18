function Z = calculateAUC(delays,dfSamples, shouldPlot)

assert(isrow(delays), 'delays must be a row vector, ie [1, N]')
assert(size(dfSamples,2)==numel(delays),'dfSamples must have same number of columns as delays')

%% Add new column representing delay=0
nSamples = size(dfSamples,1);
delays = [0 delays];
dfSamples = [ones(nSamples,1) , dfSamples];

%% Normalise delays
delays = delays ./ max(delays);

%% Calculate trapezoidal AUC
Z = zeros(nSamples,1);
for s=1:nSamples
	Z(s) = trapz(delays,dfSamples(s,:));
end

%% Plot
if shouldPlot
	histogram(Z, 'Normalization','probability',...
		'EdgeColor','none')
	set(gca,...
		'box','off')
	xlabel('Area Under Curve')
end