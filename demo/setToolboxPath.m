function toolboxPath = setToolboxPath(toolboxPath)

%% Add toolboxPath to Matlab path
% expand home dir (~) to absolute path
if strncmp(toolboxPath, '~', 1)
	toolboxPath = [getenv('HOME') toolboxPath(2:end)];
end

if exist(toolboxPath,'dir') == 7
	addpath(toolboxPath)
else
	error('change the toolboxPath to point to the folder /ddToolbox')
end

%% Add subdirectories to Matlab path
try
	addSubFoldersToPath()
catch
	error('Some error in adding toolbox subpaths')
end

%% Ensure dependencies are installed and up-to-date.
checkDependencies();

return
