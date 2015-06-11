function [y1handle, y2handle, h] = fill_between(x, y1, y2, where, varargin)
% function originally written by Ben Vincent, July 2014. Inspired by a
% function of the same name available in the Matplotlib Python library.

% Save current axes so it can't change during runtime
ca = gca;

% Check hold status so we can return things to how they were 
initialHoldState = ishold(ca);
hold(ca, 'on');

% Ensure x, y1, y2 are row vectors
if ~isrow(x)
    x=x.';
end
if ~isrow(y1)
    y1=y1.';
end
if ~isrow(y2)
    y2=y2.';
end

% if no 'where' vector is provided...
if isempty(where)
    where = ones(size(x));
end

% if where = 1 then we assume we want to fill all regions
if isequal(where, 1)
    where = ones(size(x));
end

% see if y1 OR y2 are constants
nx = numel(x);
ny1 = numel(y1);
ny2 = numel(y2); 
if nx == ny1 || nx == ny2
	%fine
else
	error('Either y1 or y2 have to be the same size as x')
end

if ny1 == 1
	y1 = y1*ones(size(x));
end

if ny2 == 1
	y2 = y2*ones(size(x));
end

%%
% Check to see if 'where' contains just one zone, or many zones. We'll need
% to draw a patch for each zone. We are going to create a vector which will
% take on values of 0 for areas we will not fill, and areas >1 for areas we
% will fill. This vector will be integer valued, the number describing the
% region number.
if where(1)
    region = 1;
else
    region = 0;
end
cat(1) = region;
% Now loop through the remaining entries
for n=2:numel(where)
    if where(n)==1 && where(n-1)==0
        % new region
        region=region+1;
    end
    if where(n)==0
        cat(n)=0;
    else
        cat(n)=region;
    end
end

% Now call the fill function for each  
if max(cat)==0
    error('no area to fill');
end
for n = 1:max(cat)
    % ---------------------------------
    h(n) = fill_patch(x, y1, y2, cat == n);
    % ---------------------------------
end


%% Now plot the full x,y1 and x,y2 lines
hold on
y1handle = plot(x,y1,'k-');
y2handle = plot(x,y2,'k-');



%% Apply formatting

% cycle through options provided and apply them. These are patch properties
% which are listed here:
% http://www.mathworks.co.uk/help/matlab/ref/patch_props.html
set(h, varargin{:});

% move it to the back
uistack(h, 'bottom')

% return to initial hold state
if initialHoldState==0
	hold(ca, 'off');
end

% make sure none of the fills run over the axes
set(ca,'Layer','top')

end


function h = fill_patch(x, y1, y2, where)
% Draw the filled patch 

default_col=[1 0 0];

x =[x(where), fliplr(x(where))];
y =[y1(where), fliplr(y2(where))];

% DRAW THE PATCH --------
h = patch(x, y, default_col);
% -----------------------

end