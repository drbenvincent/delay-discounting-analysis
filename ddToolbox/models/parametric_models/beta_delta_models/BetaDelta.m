classdef (Abstract) BetaDelta < Parametric
	%Hyperbolic1  Hyperbolic1 is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = BetaDelta(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_BetaDelta;

			% Create variables
			obj.varList.participantLevel = {'beta','delta','epsilon'};
			obj.varList.monitored = {'log_lik', 'beta','delta', 'alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
    		obj.varList.discountFunctionParams(1).name = 'beta';
			obj.varList.discountFunctionParams(1).label = '$\beta$';
			obj.varList.discountFunctionParams(2).name = 'delta';
			obj.varList.discountFunctionParams(2).label = '$delta$';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = beta * delta^delay)')
        end
    end

end
