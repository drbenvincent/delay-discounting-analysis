function doesExist = ensureFolderExists(folderPath)

doesExist = ~(exist(folderPath,'dir') ~= 7);
if ~doesExist
  mkdir(folderPath)
  doesExist = true;
end
return
