classdef mcmcContainer < handle
	%mcmc

	properties (Access = public)
		samples
	end

	methods(Abstract, Access = public)
		convergenceSummary()
		figUnivariateSummary()
		getStats()
		getSamplesAsMatrix()
		getSamples()
		getSamplesFromParticipantAsMatrix()
		getSamplesAtIndex()
	end

	methods (Access = public)

		function obj = mcmcContainer()
		end

  end

end
