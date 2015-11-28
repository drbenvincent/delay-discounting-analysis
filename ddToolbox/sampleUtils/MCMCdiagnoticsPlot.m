function MCMCdiagnoticsPlot(samples,stats,trueValue,fields, supp, paramString, data, modelType)
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

if numel(trueValue)>0
	PLOT_trueValue_VALUE=1;
else
	PLOT_trueValue_VALUE=0;
end

nSamplesDisplayLimit=10^4;


for f = 1:numel(fields) % LOOP OVER VARIABLES
	figure
	latex_fig(16, 12,4)
	
	mcmcsamples = getfield(samples, fields{f});
	[chains,Nsamples,nValues] = size(mcmcsamples);
	
	% 	if nValues==1
	
	rows = nValues;
	cols = 2; % chains, posterior
	
	% plot MCMC chains --------------
	col=1;
	for r=1:rows
		intPlotChains()
	end
	
	% plot distributions ------------
	col=2;
	for r=1:rows
		intPlotDistribution()
		% adjust positions
		% [left bottom width height]

	end
	
	if nValues==1
		hHist.Position		= [0.8 0.1 0.1 0.8];
		hChain.Position		= [0.1 0.1 0.7 0.8];
	end
	
	drawnow
	
	%% EXPORTING ---------------------
	latex_fig(16, 12,4)
	myExport(data.saveName, [modelType], ['-MCMCchain-' fields{f}])
	% -------------------------------
	
end





	function intPlotChains
		
		ksdensitySupport = supp{f};
		
		overLimitFlag=false;
		% extract samples
		if size(mcmcsamples,2)>nSamplesDisplayLimit
			overLimitFlag=true;
			mcmcsamplesSubset = mcmcsamples(:,[1:nSamplesDisplayLimit],r);
		else
			mcmcsamplesSubset = mcmcsamples(:,:,r);
		end
		
		% select the right subplot
		hChain = subplot(rows,cols,[(cols*r)-cols+1 : (cols*r)-1]);
		
		p=plot(mcmcsamplesSubset',...
			'LineWidth',0.5);
		%         %make lines transparent
		%         for c=1:chains
		%             p(c).Color(4) = 0.1;
		%         end
		
		if PLOT_trueValue_VALUE
			trueValueValue = getfield(trueValue, fields{f});
			hline(trueValueValue(r));
		end
		 
		ylabel(sprintf('$$ %s $$', paramString{f}),...
			'Interpreter','latex')
		%set(gca,'XTick',[0:1000:samplesPerChainDisplayed])
		
		%%
		% print Rhat statistic
		rhat = getfield(stats.Rhat, fields{f});
		rhat= rhat(r);
		% 		addTextToFigure('T',...
		% 			['$\hat{R}$ = ' num2str(rhat)],...
		% 			16, 'latex');
		str = sprintf('$$ \\hat{R} = %1.5f$$', rhat);
		h = addTextToFigure('T',str, 16, 'latex');
		h.BackgroundColor=[1 1 1 0.7];
		
		box off
		
		if overLimitFlag
			addTextToFigure('TR','up to the first 10,000 samples',8);
		end
		
		if r==rows
			xlabel('MCMC sample')
		end
		
	end


	function intPlotDistribution
		% select the right subplot
		hHist = subplot(rows,cols,(cols*r));
		
		% extract samples
		mcmcsamplesSubset = mcmcsamples(:,:,r);
		mcmcsamplesSubset=mcmcsamplesSubset(:);
		
		plotMCMCdist(mcmcsamplesSubset,[]);
	end

end
