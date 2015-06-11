function [lineHandles]=my_errorbarsUL(X,U,L,opts)
% U = upper
% L = lower

l=zeros(numel(X),1);

for n=1:numel(X)
	lineHandles(n) = line([X(n) X(n)],[U(n) L(n)]);
end

%% Apply formatting

% cycle through options provided and apply them. These are patch properties
% which are listed here:
% http://www.mathworks.co.uk/help/matlab/ref/patch_props.html
for n=1:2:numel(opts)
    set(lineHandles, opts{n}, opts{n+1});
end