function cellArrayOfFilenames = allFilesInFolder(path,extension)
% return a cell array of all filenames (of specified extension) in the folder specified
searchString = [path '/*.' extension];
files = dir(searchString);
cellArrayOfFilenames = {files.name};
return
