classdef (Abstract) Hyperbolic1 < Parametric
	%Hyperbolic1  Hyperbolic1 is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = Hyperbolic1(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_Hyperbolic1;

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'logk','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
    	obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = 1 / (1+k*delay)')
        end
    end

end
