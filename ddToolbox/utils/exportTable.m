function exportTable(myTable, savePath)

% ensure target location exists
[folderPath, ~] = fileparts(savePath);
ensureFolderExists(folderPath)

% export
writetable(myTable, savePath,...
	'Delimiter','\t',...
	'WriteRowNames',true)
fprintf('Table was exported to:\n')
fprintf('\t%s\n\n',savePath)
end