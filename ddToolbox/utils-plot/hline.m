function out=hline(h, varargin)
%HLINE  Adds a horizontal/vertical line to current figure
%  hline(h) adds horizontal line at h
%  hline([],v) adds vertical line at v
%
% hline(h, 'Color','r', ) 

% Marko Laine <marko.laine@fmi.fi>
% $Revision: 1.4 $  $Date: 2012/09/27 11:47:36 $

ax=get(gcf,'CurrentAxes');
ylim=get(ax,'YLim');
xlim=get(ax,'Xlim');

% if isempty(h)
%    h=line([v v], ylim); % vertical line
% else
   h=line(xlim, [h h]); % horizontal line
%end

% Apply default formatting
set(h,'Color','r');
set(h,'LineStyle','-');
set(h,'LineWidth',0.5);

% Apply formatting provided
temp = set(h,varargin{:});

% send the line to the back
uistack(h,'bottom');

if nargout>0
   out=h;
end