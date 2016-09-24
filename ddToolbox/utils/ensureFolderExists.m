function doesExist = ensureFolderExists(folderPath)

doesExist = ~(exist(folderPath,'dir') ~= 7);

if doesExist, return, end

[parentDirectory, dirName] = fileparts(folderPath);

if isempty(parentDirectory)
	% folderPath is just a local folder name?
	mkdir(dirName)
	doesExist = true;
else
	mkdir(parentDirectory, dirName)
	doesExist = true;
end
return
