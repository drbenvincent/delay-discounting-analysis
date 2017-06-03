classdef (Abstract) Hyperboloid < SubjectiveTimeModel
	%Hyperboloid  Hyperboloid is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = Hyperboloid(data, varargin)
			obj = obj@SubjectiveTimeModel(data, varargin{:});

			obj.dfClass = @DF_Hyperboloid;
            obj.subjectiveTimeFunctionFH = @SubjectiveTimeWebber;
            
			% Create variables
			obj.varList.participantLevel = {'logk','S','alpha','epsilon'};
			obj.varList.monitored = {'logk','S','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';
            obj.varList.discountFunctionParams(2).name = 'S';
            obj.varList.discountFunctionParams(2).label = 'S';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

end
