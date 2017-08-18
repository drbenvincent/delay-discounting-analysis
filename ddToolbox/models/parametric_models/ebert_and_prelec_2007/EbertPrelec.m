classdef (Abstract) EbertPrelec < SubjectiveTimeModel

	methods (Access = public)

		function obj = EbertPrelec(data, varargin)
			obj = obj@SubjectiveTimeModel(data, varargin{:});
            
            obj.dfClass = @DF_EbertPrelec;
            obj.subjectiveTimeFunctionFH = @SubjectiveTimePowerFunctionEP;

			% Create variables
			obj.varList.participantLevel = {'k','tau','alpha','epsilon'};
			obj.varList.monitored = {'k','tau','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';
            obj.varList.discountFunctionParams(2).name = 'tau';
            obj.varList.discountFunctionParams(2).label = 'tau';
            
            obj.plotOptions.dataPlotType = '2D';
		end

    end
    
    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: V = reward * exp(-(k*delay)^tau)')
            display('Ebert, J. E. J., & Prelec, D. (2007). The Fragility of Time: Time-Insensitivity and Valuation of the Near and Far Future. Management Science, 53(9), 1423-1438.')
        end
    end
    
end
