function MCMCdiagnoticsPlot(samples,stats,trueValue,fields, supp, paramString)
%
% MCMCdiagnoticsPlot(samples,stats,{'a','b','c'})
%
% MCMCdiagnoticsPlot(samples,stats,{'varint','lr','b'})
%
% This function plots chains and posterior distributions of MCMC samples.
% All the MCMC samples are assumed to be in a structure such as:
%	samples.a
%	samples.b
%	samples.c
%

if ~isempty(trueValue)
	PLOT_trueValue_VALUE=1;
else
	PLOT_trueValue_VALUE=0;
end


for f = 1:numel(fields)
	
	% NEW FIGURE FOR EACH FIELD
	figure
	latex_fig(16, 12,10)
	
	mcmcsamples = getfield(samples, fields{f});
	[chains,Nsamples,rows] = size(mcmcsamples);
	
	hChain=[];
	for row=1:rows
		rhat = getfield(stats.Rhat, fields{f});
		rhat= rhat(row);
		% plot MCMC chains --------------
		hChain(row) = intPlotChain(mcmcsamples(:,:,row), row, rows, paramString{f}, rhat);
		% plot distributions ------------
		intPlotDistribution(mcmcsamples(:,:,row), row, rows)
	end
	
	linkaxes(hChain,'x')
	
end

return




function hChain = intPlotChain(samples, row, rows, paramString, rhat)

assert(size(samples,3)==1)
% select the right subplot
start = (6*row)-(6-1);
hChain = subplot(rows,6,[start:(start-1)+(6-1)]);

h = plot(samples', 'LineWidth',0.5);

ylabel(sprintf('$$ %s $$', paramString), 'Interpreter','latex')

str = sprintf('$$ \\hat{R} = %1.5f$$', rhat);
hText = addTextToFigure('T',str, 10, 'latex');
if rhat<1.01
	hText.BackgroundColor=[1 1 1 0.7];
else
	hText.BackgroundColor=[1 0 0 0.7];
end

box off

if row~=rows
	set(gca,'XTick',[])
end
if row==rows
	xlabel('MCMC sample')
end

return


function intPlotDistribution(samples, row, rows)
% select the right subplot
hHist = subplot(rows,6,row*6);
plotMCMCdist(samples,[]);
return