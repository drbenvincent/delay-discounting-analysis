function ensureFolderExists(folderPath)
if exist(folderPath,'dir') ~= 7
  mkdir(folderPath)
end
return
