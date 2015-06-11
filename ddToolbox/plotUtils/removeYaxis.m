function removeYaxis

box off

% Remove y-axis labels
set(gca,'yticklabel',{},...
	'YTick',[])

% 'remove' y-axis by making it white
set(gca,'YColor','w')

return