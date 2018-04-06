classdef (Abstract) HyperbolicUtility < Parametric
	%HyperboloidSuper  

	methods (Access = public)

		function obj = HyperbolicUtility(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_HyperbolicUtility;
            %obj.subjectiveTimeFunctionFH = @SubjectiveTimePower;

			% Create variables
			obj.varList.participantLevel = {'logk', 'U', 'alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'logk', 'U', 'alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'logk';
			obj.varList.discountFunctionParams(1).label = '$\log(k)$';
            obj.varList.discountFunctionParams(2).name = 'U';
            obj.varList.discountFunctionParams(2).label = 'U';

			obj.plotOptions.dataPlotType = '2D';
		end

	end

    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = 1.^U / (1+k*(delay))')
        end
    end

end
