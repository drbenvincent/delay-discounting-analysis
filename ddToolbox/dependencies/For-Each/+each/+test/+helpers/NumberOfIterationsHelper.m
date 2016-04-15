%  Copyright 2014 The MathWorks, Inc.
classdef NumberOfIterationsHelper < each.iterators.Iterable
    methods
        function obj = NumberOfIterationsHelper(Array)
            obj.NumberOfIterations = Array;
        end
        
        function elem = getValue(~,~)
            elem = [];
        end
    end
end