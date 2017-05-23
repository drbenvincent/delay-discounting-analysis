function exportTable(myTable, savePath)

[folderPath, ~] = fileparts(savePath);
ensureFolderExists(folderPath)

writetable(myTable, savePath,...
	'Delimiter',',',...
	'WriteRowNames',true)
	
fprintf('Table was exported to:\n')
fprintf('\t%s\n\n',savePath)
end
