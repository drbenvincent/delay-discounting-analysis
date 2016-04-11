function [h,BayesFactor]=plotMCMCdist(posteriorSamples, kwargs)
% This function visualises distributions of MCMC samples.
% it can plot just a posterior distribution, or a posterior and a prior.
%
% Inpsired by diagrams in Kruschke (2015) Doing Bayesian Data Analysis
% Written by: Bejamin Vincent, www.inferenceLab.com

error('WHO IS CALLING ME?')

hold off

% Default options
% opts.posteriorSamples = [];
opts.postColor = [0 0 1];
opts.postAlpha = 0.5;
opts.priorColor = [1 0 0];
opts.priorAlpha = 0.5;
opts.priorSamples = [];
opts.supp = [];
opts.xi = [];
opts.nbins = 50;
opts.xscale = 'linear'; % 'linear' or 'log'
opts.trueValue = [];
opts.bayesFactorXvalue = [];
opts.plotPosteriorHDI = true;
opts.PlotBoxAspectRatio=[];
opts.plotStyle = 'histogram'; % 'histogram' or 'line' or 'lineFilled'
opts.xLabel =[];
opts.ksdensitySupport =[-inf inf]; % '[]' or 'positive' or [L U]
% if we are asking for a Bayes Factor, then I'm going to enforce plotting
% as a line
if numel(opts.bayesFactorXvalue)>0
	opts.plotStyle = 'line';
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
opts = kwargify(opts,kwargs);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% If we are plitting lines (not histograms) then we want the lines to be
% black
switch opts.plotStyle
	case{'line', 'lineFilled'}
		opts.priorColor='k';
		opts.postColor='k';
end

% Have samples from prior been provided?
if numel(opts.priorSamples)>1
	opts.doPrior = true;
else
	opts.doPrior = false;
end

% % check samples are in the form of vectors. Sometimes they might come in
% % with seperate columns for each MCMC chain
% if opts.doPrior, opts.priorSamples=opts.priorSamples(:); end
% posteriorSamples=posteriorSamples(:);




% Deal with xi ---------------------------------
tempAllSamples = [posteriorSamples(:);opts.priorSamples(:)];

if numel(opts.xi)==0 % xi not provided, so automatically compute it

	switch opts.xscale
		case{'linear'}
			opts.xi = linspace( min(tempAllSamples), max(tempAllSamples), opts.nbins);
		case{'log'}
			[~,opts.xi] = hist(log(tempAllSamples), opts.nbins);
	end

elseif numel(opts.xi)==1 % number of bins provided, but compute xi vector

	switch opts.xscale
		case{'linear'}
			%opts.nbins = opts.xi;
			opts.xi = linspace( min(tempAllSamples), max(tempAllSamples), opts.nbins);
		case{'log'}
			[~,opts.xi] = hist(log(tempAllSamples), opts.nbins);
	end

elseif numel(opts.xi)>1
	% xi provided
	opts.nbins = numel(opts.xi);
end
clear tempAllSamples


%% PRIOR
% plot the prior if samples of the prior are provided

% for plotting the prior, temporarily turn off the plot HDI flag
			tempHDIflag = opts.plotPosteriorHDI;
			opts.plotPosteriorHDI=false;

if opts.doPrior
	switch opts.plotStyle
		case{'histogram'}
			% plot prior
			hold off
			hPrior=histogram(opts.priorSamples(:), opts.xi);

			% format prior
			hPrior.FaceColor =opts.priorColor;
			hPrior.FaceAlpha = opts.priorAlpha;
			internalFormatHist(hPrior)

		case{'line'}
			% do kernel density estimate
			[hPrior, BFpriorDensity] = internalPlotDensity(opts.priorSamples(:), opts);
			set(hPrior,'Color',opts.priorColor)
			hPrior.LineStyle ='--';

		case{'lineFilled'}

			[hPrior, BFpriorDensity] = internalPlotDensity(opts.priorSamples(:), opts);
			%set(hPrior,'Color',opts.priorColor)
			hPrior.LineStyle ='--';
			hPrior.Color = opts.priorColor;

	end
	hold on
end

% switch flag back to what it was
opts.plotPosteriorHDI=tempHDIflag;



%% POSTERIOR
switch opts.plotStyle
	case{'histogram'}
		hPost=histogram(posteriorSamples(:), opts.xi);

		% format posterior
		hPost.FaceColor=opts.postColor;
		hPost.FaceAlpha = opts.postAlpha;
		internalFormatHist(hPost)

	case{'line'}
		% plot line and HDI as a line
		[hPost, BFpostDensity] = internalPlotDensity(posteriorSamples(:), opts);
		set(hPost,'Color',opts.postColor)

	case{'lineFilled'}
		% plot line and HDI as a filled region
		[hPost, BFpostDensity] = internalPlotDensity(posteriorSamples(:), opts);
end

%% Format Axes
box off
% Remove y-axis labels
set(gca,'yticklabel',{},...
	'YTick',[])
% 'remove' y-axis by making it white
set(gca,'YColor','w')
% set axis layer to bottom because 95% interval text can overlap with it
set(gca,'Layer','bottom')
% ------------------------------
% zoom x limits to posterior distribution
%autoXlim(posteriorSamples, supp)
% ------------------------------
set(gca,'TickDir','out')
% log x-axis?
switch opts.xscale
	case{'log'}
		set(gca,'XScale','log')
end

% xlabel
if numel(opts.xLabel)>0
	xlabel(opts.xLabel)
end

%% plot true values, if there are any provided
if numel(opts.trueValue)>0
	plot(opts.trueValue, 0, '.',...
		'MarkerSize',5^2,...
		'Color','k');
end

%% legend
% if opts.doPrior
% 	legend([hPrior hPost],{'prior','posterior'})
% end
% legend boxoff




		% ----------------------
		internalShowHDI(posteriorSamples, opts)
		% ----------------------



if numel(opts.PlotBoxAspectRatio)>0
	set(gca,'PlotBoxAspectRatio',opts.PlotBoxAspectRatio)
end




%% Bayes Factor
if numel(opts.bayesFactorXvalue) > 0 ...
		&& exist('BFpriorDensity')...
		&& exist('BFpostDensity')

	BayesFactor = BFpostDensity / BFpriorDensity;

	%txt=sprintf('Bayes Factor = %3.2f', BayesFactor);
	%addTextToFigure('TL',txt,16)

	% plot arrow
	x = [opts.bayesFactorXvalue opts.bayesFactorXvalue];
	y = [BFpriorDensity BFpostDensity];
	myarrow(x,y)

	% add "x BF"
	bf=sprintf('%3.2f', BayesFactor);
	t=text(opts.bayesFactorXvalue,mean(y),'temp',...
		'Interpreter','latex',...
		'BackgroundColor','w');

	t.String=[' $$ \times $$' bf];

end

return













function internalShowHDI(samples, opts)
% Calculate HDI
switch opts.xscale
	case{'linear'}
		[HDI] = HDIofSamples(samples, 0.95);
	case{'log'}
		[HDI] = exp( HDIofSamples(log(samples), 0.95) );
end
% % Plot 95% CI
hold on
% Y = prctile(samples(:),[5 95]);

a = axis; top = a(4); k=0.03;
% Plot horizontal HDI line?
switch opts.plotStyle
	case{'line'}
		plot(HDI,[top*k top*k],'k-', 'LineWidth',2);
end

% Add numbers to the CI
lower = sprintf('%.4f',HDI(1));
upper = sprintf('%.4f',HDI(2));
% normal, horizontal text ------------------
% t1=text(HDI(1),top*k , lower,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','bottom',...
% 	'FontSize',14,...
% 	'BackgroundColor','w');
% t2=text(HDI(2),top*k , upper,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','bottom',...
% 	'FontSize',14,...
% 	'BackgroundColor','w');

% vertical text ----------------------------
k=0.055;
t1=text(HDI(1),top*k , lower,...
	'HorizontalAlignment','left',...
	'VerticalAlignment','middle',...
	'FontSize',14,...
	'BackgroundColor','none',...
	'Rotation',90);
t2=text(HDI(2),top*k , upper,...
	'HorizontalAlignment','left',...
	'VerticalAlignment','middle',...
	'FontSize',14,...
	'BackgroundColor','none',...
	'Rotation',90);

% make sure text is on top
uistack(t1,'top');
uistack(t2,'top');
return




% function internalShowHDIregion(samples)
% % Calculate HDI
% [HDI] = HDIofSamples(samples, 0.95);
% % % Plot 95% CI
% hold on
% % Y = prctile(samples(:),[5 95]);
% a = axis; top = a(4); k=0.03;
% %plot(HDI,[top*k top*k],'k-', 'LineWidth',2);
%
% where = x>0 & x<pi/2;
% h = fill_between(x,y1,y2, where, opts);
%
% % Add numbers to the CI
% lower = sprintf('%.4f',HDI(1));
% upper = sprintf('%.4f',HDI(2));
% % normal, horizontal text
% % t1=text(HDI(1),top*k , lower,...
% % 	'HorizontalAlignment','center',...
% % 	'VerticalAlignment','bottom',...
% % 	'FontSize',14,...
% % 	'BackgroundColor','w');
% % t2=text(HDI(2),top*k , upper,...
% % 	'HorizontalAlignment','center',...
% % 	'VerticalAlignment','bottom',...
% % 	'FontSize',14,...
% % 	'BackgroundColor','w');
% % vertical text
% k=0.055;
% t1=text(HDI(1),top*k , lower,...
% 	'HorizontalAlignment','left',...
% 	'VerticalAlignment','middle',...
% 	'FontSize',14,...
% 	'BackgroundColor','none',...
% 	'Rotation',90);
% t2=text(HDI(2),top*k , upper,...
% 	'HorizontalAlignment','left',...
% 	'VerticalAlignment','middle',...
% 	'FontSize',14,...
% 	'BackgroundColor','none',...
% 	'Rotation',90);
% % make sure text is on top
% uistack(t1,'top');
% uistack(t2,'top');
% return





function internalFormatHist(h)
h.Normalization = 'probability';
h.EdgeColor='none';
return



function [h, density] = internalPlotDensity(samples, opts)
%% KERNEL DENSITY ESTIMATION
density=[];
if numel(opts.bayesFactorXvalue)>0
	% ensure the exact x-axis value we want for the Bayes factor is
	% included in xi
	if sum(opts.xi==opts.bayesFactorXvalue)==0
		opts.xi=[opts.xi opts.bayesFactorXvalue];
		opts.xi=sort(opts.xi);
	end
end

f	= ksdensity(samples(:), opts.xi,...
	'function','pdf',...
	'support',opts.ksdensitySupport);

f = f./sum(f);

%h = plot(opts.xi,f);

% return density at the bayesFactorXvalue
if numel(opts.bayesFactorXvalue)>0
	density = f( opts.xi==opts.bayesFactorXvalue );
end

%% PLOT VIA KERNEL DENSITY ESTIMATION
%h = plot(opts.xi,f);
%% PLOT VIA HISOGRAM
switch opts.xscale
	case{'log'}
		[f,~] = hist(log(samples(:)), opts.xi);
	case{'linear'}
		[f,~] = hist(samples(:), opts.xi);
end

f=f./sum(f); % normalise

switch opts.plotStyle
	case{'line'}
		% plot just a line for the distribution, but also HDI interval as a
		% line

		switch opts.xscale
			case{'log'}
				h = semilogx(exp(opts.xi),f);
			case{'linear'}
				h = plot(opts.xi,f);
		end


	case{'lineFilled'}
		if opts.plotPosteriorHDI
			% plot distribution as a line, but fill the HDI interval with color
			[HDI] = HDIofSamples(samples(:), 0.95);

			% Use my fill_between function
			where = opts.xi>HDI(1) & opts.xi<HDI(2);
			y1 = f;
			y2  = zeros(size(opts.xi));
			fillopts={};
			fillopts={'EdgeColor', 'k',...
				'FaceColor',[0.5 0.5 1]};
			try
				switch opts.xscale
					case{'log'}
						[y1handle, y2handle, h] = fill_between(exp(opts.xi), y1, y2, where);
					case{'linear'}
						[y1handle, y2handle, h] = fill_between(opts.xi, y1, y2, where);
				end
				%[y1handle, y2handle, h] = fill_between(opts.xi, y1, y2, where);
			end

			h.EdgeColor='none';
			h.FaceColor=[0.8 0.8 0.8];
		else
			h = plot(opts.xi,f);
		end
end

return




function myarrow(xo,yo)

% Matlab is rather stupid. You can't plot arrows in data space, only in
% normalised figure space. So you have to convert data space to figure
% space. I used a solution offered here:
% http://stackoverflow.com/questions/11499370/how-to-plot-arrow-onto-a-figure-in-matlab

set(gcf,'Units','normalized')
set(gca,'Units','normalized')
ax = axis;
ap = get(gca,'Position');
%% annotation
% xo = [opts.bayesFactorXvalue opts.bayesFactorXvalue];
% yo = [BFpriorDensity BFpostDensity];
xp = (xo-ax(1))/(ax(2)-ax(1))*ap(3)+ap(1);
yp = (yo-ax(3))/(ax(4)-ax(3))*ap(4)+ap(2);
ah=annotation('arrow',xp,yp,...
	'HeadStyle','deltoid');

return
