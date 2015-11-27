% setPlotTheme 
%
% Changes a few defaults to make plots nicer

set(0,'DefaultFigurePaperType', 'A4');
%set(0,'DefaultFigureWindowStyle', 'normal');	% 'normal' or 'docked'

set(groot,'DefaultAxesBox', 'off');
set(groot,'DefaultFigureColor',[1 1 1])

set(groot,'DefaultAxesLineWidth',1)
set(groot,'DefaultLineLineWidth',1)

set(groot,'defaultaxesfontsize',14)
set(groot,'defaulttextfontsize',14)

set(groot,'DefaultAxesLayer','top')
set(groot,'DefaultAxesTickLength',[0.01 0.005])

%set(groot,'DefaultAxesTickDirMode','manual')
set(groot,'DefaultAxesTickDir','out')
set(0,'DefaultAxesTickDir', 'out')

display('plotting defaults loaded')