function [figureHandle, axisHandle] = parseFigureAndAxisRequested(varargin)

p = inputParser;
p.KeepUnmatched = true;
p.FunctionName = mfilename;
p.addParameter('figureHandle', gcf, @ishandle);
p.addParameter('axisHandle', gca, @ishandle);
p.parse(varargin{:});

figureHandle = p.Results.figureHandle;
axisHandle = p.Results.axisHandle;

figure(figureHandle)
subplot(axisHandle)

end
