classdef Variable < handle
	%Variable
	%	xxxx

	properties (Access = public)
		str
		str_latex
		bounds
		monitoredFlag
		rnd % function handle to generate initial values
	end

	properties (GetAccess = public, SetAccess = protected)
		analyses % struct
	end

  methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = Variable(str, str_latex, bounds, monitoredFlag, rnd)
			obj.str = str;
			obj.str_latex = str_latex;
			obj.bounds = bounds;
			obj.monitoredFlag = monitoredFlag;
			obj.rnd = rnd;
		end


  end

end
