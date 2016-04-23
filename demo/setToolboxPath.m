function toolboxPath = setToolboxPath(toolboxPath)
% *** SET THIS TO THE PATH OF THE /ddToolbox FOLDER ***

% expand home dir (~) to absolute path
if strncmp(toolboxPath, '~', 1)
	toolboxPath = [getenv('HOME') toolboxPath(2:end)];
end
	
try
	% check that this folder exists
	if exist(toolboxPath,'dir')~=7
		error('change the toolboxPath to point to the folder /ddToolbox')
	end
	addpath(genpath(toolboxPath))
catch
	error('change the toolboxPath to point to the folder /ddToolbox')
end
return
