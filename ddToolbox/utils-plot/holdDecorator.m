function [outputs] = holdDecorator(plotFunction)
% This is a decorator function which does some work before and after the 
% provided plotFunction is exectuted. In this case, we are setting the hold 
% state of a figure to be on, then returning to it's original state.
%
% We assume plotFunction() is self contained, in that calling it will work
% without any need for input arguments. So we may well have created a
% partial function before, eg:
%   plotFunc = @() myPlottingFunction(x, y, options);
%   outputs = holdDecorator(plotFunc)

% NOTE: here we do wrapping and exectution. It is also possible to return a
% function which is decorated.

%% 1. before steps
initial_hold_state = ishold(gca);
hold on

%% 2. call the function
[outputs] = plotFunction();

%% 3. after steps
if initial_hold_state == 0
	hold off
end

end