function setPlotTheme(varargin)
%
% Changes a few defaults to make plots nicer

p = inputParser;
p.FunctionName = mfilename;
p.addParameter('fontsize',14,@isscalar);
%p.addParameter('docked',false,@islogical);
p.addParameter('linewidth',1,@isscalar);
p.parse(varargin{:});
			
set(0,'DefaultFigurePaperType', 'A4');
%set(0,'DefaultFigureWindowStyle', 'normal');	% 'normal' or 'docked'

set(groot,'DefaultAxesBox', 'off');
set(groot,'DefaultFigureColor',[1 1 1])

set(groot,'DefaultAxesLineWidth',p.Results.linewidth)
set(groot,'DefaultLineLineWidth',p.Results.linewidth)

set(groot,'defaultaxesfontsize', p.Results.fontsize)
set(groot,'defaulttextfontsize', p.Results.fontsize)

set(groot,'DefaultAxesLayer','top')
set(groot,'DefaultAxesTickLength',[0.01 0.005])

%set(groot,'DefaultAxesTickDirMode','manual')
set(groot,'DefaultAxesTickDir','out')
set(0,'DefaultAxesTickDir', 'out')

display('plotting defaults set')
return