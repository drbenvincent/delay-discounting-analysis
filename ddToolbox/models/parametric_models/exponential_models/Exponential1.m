classdef (Abstract) Exponential1 < Parametric

	methods (Access = public)

		function obj = Exponential1(data, varargin)
			obj = obj@Parametric(data, varargin{:});

            obj.dfClass = @DF_Exponential1;

			% Create variables
			obj.varList.participantLevel = {'k','alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'k','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';

            obj.plotOptions.dataPlotType = '2D';
		end

	end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = exp(-k.delay)')
        end
    end

end
