classdef ModelHierarchicalMEUpdated < ModelHierarchicalME
	%ModelHierarchicalMEUpdated A model to estimate the magnitide effect
	%   Extends ModelHierarchical but uses new JAGS model with new priors.

	properties
	end

	methods (Access = public)

		function obj = ModelHierarchicalMEUpdated(toolboxPath, samplerType, data, saveFolder, varargin)

            samplerType     = lower(samplerType);
            modelType		= 'hierarchicalMEupdated';
            modelPath		= [toolboxPath '/models/' modelType '.' samplerType];

			% ** NOTE: this call is different **
			obj = obj@ModelHierarchicalME(toolboxPath, 'JAGS', data, saveFolder, varargin{:});

		end

	end

end
