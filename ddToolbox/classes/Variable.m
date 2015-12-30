classdef Variable < handle
	%Variable

	properties (Access = public)
		str
		str_latex
		bounds
		monitoredFlag
		analysisFlag
		plotMCMCchainFlag
		seed
	end

	properties (GetAccess = public, SetAccess = protected)
		analyses % struct
	end

  methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = Variable(str, str_latex, bounds, monitoredFlag)
			obj.str = str;
			obj.str_latex = str_latex;
			obj.bounds = bounds;
			obj.monitoredFlag = monitoredFlag;
			obj.analysisFlag = false; % default
			obj.plotMCMCchainFlag = true; % default
			obj.seed = []; % empty by default
		end


  end

end
