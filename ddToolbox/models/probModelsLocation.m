function path = probModelsLocation()
% This function will return its location
full = mfilename('fullpath');
[path, ~] = fileparts(full);
return
