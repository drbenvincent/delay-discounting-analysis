function plotTriPlotWrapper(plotdata)
figure(87)

% Checks
% The variables we are being asked to plot are the fields of plotdata.samples.posterior
% We need to check and remove fields for which there are no samples (either
% empty, or NaN)
fields = fieldnames(plotdata.samples.posterior);
for n = 1:numel(fields)
	if any(isnan(plotdata.samples.posterior.(fields{n}))) || isempty(plotdata.samples.posterior.(fields{n}))
		plotdata.samples.posterior = rmfield( plotdata.samples.posterior,...
			fields{n});
	end
end

[posteriorSamples, pVariableNames]	= struct2Matrix(plotdata.samples.posterior);

mcmc.TriPlotSamples(posteriorSamples,...
	pVariableNames,...
	'pointEstimateType', plotdata.pointEstimateType);

if plotdata.shouldExportPlots
	myExport(plotdata.savePath, 'triplot',...
		'prefix', plotdata.IDname{:},...
		'suffix', plotdata.modelType);
end

end