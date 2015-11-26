function projectPath = setProjectPath(projectPath)
% Set path to your project folder
try
	cd(projectPath)
catch
	error('change the projectPath to point to the folder /delay-discounting-analysis/demo')
end	
return