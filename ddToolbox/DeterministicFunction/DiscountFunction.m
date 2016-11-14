classdef (Abstract) DiscountFunction < DeterministicFunction
	%DiscountFunction 
	
	methods (Access = public)
		
		function obj = DiscountFunction()
            obj = obj@DeterministicFunction();
		end
		
    end
    
    methods (Abstract)

	end
	
end
