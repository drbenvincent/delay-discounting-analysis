classdef ModelHierarchicalMEUpdated < ModelHierarchicalME
	%ModelHierarchicalMEUpdated A model to estimate the magnitide effect
	%   Extends ModelHierarchical but uses new JAGS model with new priors.

	properties
	end

	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalMEUpdated(toolboxPath, sampler, data, saveFolder)
			% Inherit from ModelHierarchical and override selected methods
			obj = obj@ModelHierarchicalME(toolboxPath, sampler, data, saveFolder);

			switch sampler
				case{'JAGS'}
					modelPath = '/models/hierarchicalMEupdated.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
					
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end
		end
		% =================================================================

	end

end
