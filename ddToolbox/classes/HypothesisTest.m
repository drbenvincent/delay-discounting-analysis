classdef HypothesisTest < handle
	%HypothesisTest A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		function obj = HypothesisTest(toolboxPath, samplerType, data, saveFolder)
			obj = obj@ModelBaseClass(toolboxPath, samplerType, data, saveFolder);

end
end
