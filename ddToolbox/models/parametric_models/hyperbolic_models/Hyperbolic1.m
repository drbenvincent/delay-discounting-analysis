classdef (Abstract) Hyperbolic1 < Parametric
	%Hyperbolic1  Hyperbolic1 is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Hyperbolic1(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_Hyperbolic1;

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
    	obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';

			obj.dataPlotType = '2D';
		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

	end


	methods (Abstract)
		initialiseChainValues
	end

end
