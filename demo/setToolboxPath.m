function toolboxPath = setToolboxPath(toolboxPath)
% *** SET THIS TO THE PATH OF THE /ddToolbox FOLDER ***
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
