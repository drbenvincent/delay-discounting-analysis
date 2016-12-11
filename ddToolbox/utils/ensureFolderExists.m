function doesExist = ensureFolderExists(folderPath)

doesExist = ~(exist(folderPath,'dir') ~= 7);

if doesExist, return, end

[parentDirectory, dirName] = fileparts(folderPath);

if isempty(parentDirectory)
	% folderPath is just a local folder name?
	[SUCCESS,MESSAGE,MESSAGEID] = mkdir(dirName);
	doesExist = true;
else
	[SUCCESS,MESSAGE,MESSAGEID] = mkdir(parentDirectory, dirName);
	doesExist = true;
end

if ~SUCCESS
	disp(MESSAGE)
	disp(MESSAGEID)
end

return
