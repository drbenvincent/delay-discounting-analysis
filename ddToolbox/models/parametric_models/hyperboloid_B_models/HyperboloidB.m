classdef (Abstract) HyperboloidB < SubjectiveTimeModel
	%HyperboloidB  HyperboloidB is a subclass of Model for examining the B 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = HyperboloidB(data, varargin)
			obj = obj@SubjectiveTimeModel(data, varargin{:});

			obj.dfClass = @DF_HyperboloidB;
            obj.subjectiveTimeFunctionFH = @SubjectiveTimePower;

			% Create variables
			obj.varList.participantLevel = {'logk','S','alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'logk','S','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';
            obj.varList.discountFunctionParams(2).name = 'S';
            obj.varList.discountFunctionParams(2).label = 'S';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = 1 / (1+k*(delay^S)')
        end
    end

end
