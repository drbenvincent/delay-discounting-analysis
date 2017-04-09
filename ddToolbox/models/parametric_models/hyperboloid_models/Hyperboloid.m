classdef (Abstract) Hyperboloid < Parametric
	%Hyperboloid  Hyperboloid is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = Hyperbolic1(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_Hyperboloid;

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';
            obj.varList.discountFunctionParams(2).name = 'pow';
            obj.varList.discountFunctionParams(2).label = 'pow';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

end
