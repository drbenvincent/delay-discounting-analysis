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
        function plotExperimentOverviewFigure(obj, ind)
            %model.plotExperimentOverviewFigure(N) Creates a multi-panel figure
            %   model.plotExperimentOverviewFigure(N) creates a multi-panel figure
            %   corresponding to experiment N, where N is an integer.
            
            latex_fig(12, 14, 3)
            h = layout([1 2 3 4 5]);
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            opts.dataPlotType		= obj.plotOptions.dataPlotType;
            
            obj.plotPosteriorErrorParams(ind, 'axisHandle', h(1))
            obj.plotPsychometricFunction(ind, 'axisHandle', h(2))
            obj.plotPosteriorDiscountFunctionParams(ind, 'axisHandle', h(3))
            obj.plot_subjective_time_function(ind, 'axisHandle', h(4))
            obj.plotDiscountFunction(ind, 'axisHandle', h(5))
        end
        
	end


    methods (Access = protected)

        function plot_subjective_time_function(obj, ind, varargin)
            % plot_subjective_time_function
            % 
            % Optional arguments as key/value pairs
            %       'axisHandle' - handle to axes
            %       'figureHandle' - handle to figure
            
            [figureHandle, axisHandle] = parseFigureAndAxisRequested(varargin{:});
            
            discountFunctionVariables = obj.getDiscountFunctionVariables();
            subjectiveTimeFun = SubjectiveTimePowerFunctionEP('samples',...
                obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables));
            subjectiveTimeFun.plot(obj.plotOptions.pointEstimateType)
        end

    end
    
end
