classdef (Abstract) SubjectiveTimeModel < Parametric

    properties (SetAccess = protected, GetAccess = protected)
        subjectiveTimeFunctionFH % function handle to subjectiveTimeFun
    end

	methods (Access = public)

		function obj = SubjectiveTimeModel(data, varargin)
			obj = obj@Parametric(data, varargin{:});
		end
        
        % Override this function from superclass
        function plotExperimentOverviewFigure(obj, ind)
            latex_fig(12, 14, 3)
            h = layout([1 2 3 4 5]);
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            opts.dataPlotType		= obj.plotOptions.dataPlotType;
            
            obj.plotPosteriorErrorParams(ind, 'axisHandle', h(1))
            obj.plotPsychometricFunction(ind, 'axisHandle', h(2))
            obj.plotPosteriorDiscountFunctionParams(ind, 'axisHandle', h(3))
            obj.plotSubjectiveTimeFunction(ind, 'axisHandle', h(4))
            obj.plotDiscountFunction(ind, 'axisHandle', h(5))
        end

        function plotSubjectiveTimeFunction(obj, ind, varargin)
            % plotSubjectiveTimeFunction
            % 
            % Optional arguments as key/value pairs
            %       'axisHandle' - handle to axes
            %       'figureHandle' - handle to figure
            
            [figureHandle, axisHandle] = parseFigureAndAxisRequested(varargin{:});
            
            discountFunctionVariables = obj.getDiscountFunctionVariables();
            subjectiveTimeFun = obj.subjectiveTimeFunctionFH('samples',...
                obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables));
            subjectiveTimeFun.plot(obj.plotOptions.pointEstimateType)
        end
    
    end

end
