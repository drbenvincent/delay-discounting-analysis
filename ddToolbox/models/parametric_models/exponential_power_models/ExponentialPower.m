classdef (Abstract) ExponentialPower < SubjectiveTimeModel

	methods (Access = public)

		function obj = ExponentialPower(data, varargin)
			obj = obj@SubjectiveTimeModel(data, varargin{:});
            
            obj.dfClass = @DF_ExponentialPower;
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

end
