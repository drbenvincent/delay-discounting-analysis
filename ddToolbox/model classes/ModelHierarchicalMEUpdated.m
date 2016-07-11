classdef ModelHierarchicalMEUpdated < ModelHierarchicalME
	%ModelHierarchicalMEUpdated A model to estimate the magnitide effect
	%   Extends ModelHierarchical but uses new JAGS model with new priors.

	properties
	end

	methods (Access = public)

		function obj = ModelHierarchicalMEUpdated(data, varargin)
			obj = obj@ModelHierarchicalME(data, varargin{:});
			
			obj.modelType = 'hierarchicalMEupdated';
		end

	end

end
