classdef WAIC
    %WAIC WAIC object
    %   Extended description here
    
    properties (SetAccess = protected)
		lppd, pWAIC, WAIC_value, WAIC_standard_error
		nSamples, nCases
	end
	
	properties (Hidden = true)
		log_lik
		lppd_vec, pWAIC_vec
	end
    
    methods
        
        function obj = WAIC(log_lik)
			
			[obj.nCases, obj.nSamples] = size(log_lik);
			
			obj.log_lik = log_lik;
			clear log_lik
			
			% Calculate lppd
			obj.lppd_vec = log( mean( exp(obj.log_lik) , 2) );
			obj.lppd = sum(obj.lppd_vec);
			
			% Calculate effective number of samples, pWAIC
			obj.pWAIC_vec = var(obj.log_lik,0,2);
			obj.pWAIC = sum(obj.pWAIC_vec);
			
			% Calculate WAIC
			obj.WAIC_value = -2 * ( obj.lppd - obj.pWAIC );
			
			% Calculate standard error
			WAIC_vec = -2 * ( obj.lppd_vec - obj.pWAIC_vec );
			obj.WAIC_standard_error = sqrt(obj.nCases)*var(WAIC_vec);
			
		end
        
	end
    
end