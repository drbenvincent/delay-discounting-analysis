classdef Variable < handle
	%Variable

	properties (Access = public)
		str
		str_latex
		%bounds
		%monitoredFlag
		%analysisFlag
		%plotMCMCchainFlag
		seed
		single
	end

	properties (GetAccess = public, SetAccess = protected)
		%analyses % struct
	end

  methods (Access = public)

		function obj = Variable(str, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('str',@isstr);
			%p.addParameter('bounds',[], @isvector);
			p.addParameter('str_latex',str,@isstr);
			p.addParameter('seed',[], @(x) isa(x,'function_handle'))
			p.addParameter('single',false, @islogical)
			%p.addParameter('analysisFlag',[], @isnumeric)

			p.parse(str, varargin{:});

			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
		end

  end

end
