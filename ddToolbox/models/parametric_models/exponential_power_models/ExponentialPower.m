classdef (Abstract) ExponentialPower < SubjectiveTimeModel

	methods (Access = public)

		function obj = ExponentialPower(data, varargin)
			obj = obj@SubjectiveTimeModel(data, varargin{:});

            obj.dfClass = @DF_ExponentialPower;
            obj.subjectiveTimeFunctionFH = @SubjectiveTimePowerFunction;

			% Create variables
			obj.varList.participantLevel = {'k','logtau','alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'k','logtau','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';
            obj.varList.discountFunctionParams(2).name = 'logtau';
            obj.varList.discountFunctionParams(2).label = '$\log(\tau)$';

            obj.plotOptions.dataPlotType = '2D';
		end

    end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = reward * exp(-k*(delay^tau))')
        end
    end

end
