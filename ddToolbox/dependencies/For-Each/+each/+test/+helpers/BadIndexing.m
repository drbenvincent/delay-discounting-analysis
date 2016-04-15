%  Copyright 2014 The MathWorks, Inc.
classdef BadIndexing
    methods
        function [out] = subsref(~,varargin)
            error('iterators:test:badindexing','Indexing Not Supported');
        end
    end
end