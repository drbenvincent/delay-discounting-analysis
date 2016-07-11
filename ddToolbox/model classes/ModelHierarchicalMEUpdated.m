classdef ModelHierarchicalMEUpdated < ModelHierarchicalME
	%ModelHierarchicalMEUpdated A model to estimate the magnitide effect
	%   Extends ModelHierarchical but uses new JAGS model with new priors.

	properties
	end

	methods (Access = public)

		function obj = ModelHierarchicalMEUpdated(samplerType, data, varargin)

            samplerType     = lower(samplerType);
            modelType		= 'hierarchicalMEupdated';
            modelPath = makeProbModelsPath(modelType, samplerType);

			% ** NOTE: this call is differently **
			obj = obj@ModelHierarchicalME(samplerType, data, varargin{:});

		end

	end

end
