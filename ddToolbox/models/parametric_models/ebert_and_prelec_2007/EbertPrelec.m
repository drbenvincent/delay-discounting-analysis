classdef (Abstract) EbertPrelec < Parametric

	methods (Access = public)

		function obj = EbertPrelec(data, varargin)
			obj = obj@Parametric(data, varargin{:});
            
            obj.dfClass = @DF_EbertPrelec;

			% Create variables
			obj.varList.participantLevel = {'k','tau','alpha','epsilon'};
			obj.varList.monitored = {'k','tau','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';
            obj.varList.discountFunctionParams(2).name = 'tau';
            obj.varList.discountFunctionParams(2).label = 'tau';
            
            obj.plotOptions.dataPlotType = '2D';
		end
        
        % Override this function from superclass
        function experimentMultiPanelFigure(obj, ind)
            %model.experimentMultiPanelFigure(N) Creates a multi-panel figure
            %   model.EXPERIMENTMULTIPANELFIGURE(N) creates a multi-panel figure
            %   corresponding to experiment N, where N is an integer.
            
            latex_fig(12, 14, 3)
            h = layout([1 2 3 4 5]);
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            opts.dataPlotType		= obj.plotOptions.dataPlotType;
            
            obj.plot_density_alpha_epsilon(h(1), ind)
            obj.plot_psychometric_function(h(2), ind)
            obj.plot_discount_function_parameters(h(3), ind)
            obj.plot_subjective_time_function(h(4), ind)
            obj.plotDiscountFunction(h(5), ind)
        end
        
	end


    methods (Access = protected)

        function plot_subjective_time_function(obj, subplot_handle, ind)
            discountFunctionVariables = obj.getDiscountFunctionVariables();
            subplot(subplot_handle)
            subjectiveTimeFun = SubjectiveTimePowerFunctionEP('samples',...
                obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables));
            subjectiveTimeFun.plot(obj.plotOptions.pointEstimateType)
        end

    end
    
end
