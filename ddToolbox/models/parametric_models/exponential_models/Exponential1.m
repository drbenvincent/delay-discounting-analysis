classdef (Abstract) Exponential1 < Parametric

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Exponential1(data, varargin)
			obj = obj@Parametric(data, varargin{:});
            
            obj.dfClass = @DF_Exponential1;

			% Create variables
			obj.varList.participantLevel = {'k','alpha','epsilon'};
			obj.varList.monitored = {'k','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';
            
            obj.dataPlotType = '2D';
		end
		
	end

	
	methods (Abstract)
		initialiseChainValues
    end

end
