function cellArrayOfFilenames = allFilesInFolder(path,extension)

searchString = [path '/*.' extension];
files = dir(searchString);
cellArrayOfFilenames = {files.name};