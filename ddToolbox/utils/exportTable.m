function exportTable(myTable, savePath)
writetable(myTable, savePath,...
	'Delimiter','\t',...
	'WriteRowNames',true)
fprintf('Table was exported to:\n')
fprintf('\t%s\n\n',savePath)
end