function subplotHandles = layout(layout_matrix)
% Ben Vincent, 2016
%
% h = layout([1, 2, 2; 3 3 4])

[nrows, ncols] = size(layout_matrix);

nplots = max(layout_matrix(:));

for n=1:nplots
	occupancy = layout_matrix==n;
	indicies = find(occupancy'==true);
	subplotHandles(n) = subplot(nrows, ncols, indicies);
	%title([n])
end