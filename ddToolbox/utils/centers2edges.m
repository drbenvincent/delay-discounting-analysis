function edges = centers2edges(centers)
% see here:
% https://www.mathworks.com/examples/matlab/mw/matlab-ex22718103-convert-bin-centers-to-bin-edges
d = diff(centers)/2;
edges = [centers(1)-d(1), centers(1:end-1)+d, centers(end)+d(end)];

%warning('check that we need this next line...')
%edges(2:end) = edges(2:end)+eps(edges(2:end))
end