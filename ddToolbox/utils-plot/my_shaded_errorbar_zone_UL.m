function [h]=my_shaded_errorbar_zone_UL(x,upper,lower,col)
% Plots a shaded region of error
%
% my_shaded_errorbar_zone_UL([-10:0.1:10],[-10:0.1:10]+1,[-10:0.1:10]-1,[0.7 0.7 0.7])
%
% eg, my_shaded_errorbar_zone([-10:0.1:10],x,abs(randn(size(x)))+2,[0 0 1])
%
%handle=patch([x max(x)-x+min(x)],[y+e flipud(y'-e')'],[0.8 0.8 0.8]);
%handle=patch([x max(x)-x+min(x)],[upper flipud(lower')'],[0.8 0.8 0.8]);
%
%
% written by: Benjamin T Vincent


g=ishold(gca);
hold on

%% 
% draw the shaded error bar zone
x =[x,fliplr(x)];
y =[upper,fliplr(lower)];
h =patch(x,y,[0.8 0.8 0.8]);

% move it to the back
uistack(h,'bottom') 

% set the colour
set(h,'EdgeColor',col)
set(h,'FaceColor',col)

%set(handle,'FaceAlpha',0.5)

% leave the figure hold status as it was
if g==0
	hold off
end

return