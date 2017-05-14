classdef test_Stochastic < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function check_mode_is_NaN_when_NaN_samples_provided(testCase)
			% when we provide NaN as samples to a Stochastic object, check
			% we set obj.mode as NaN
			univariateObject = Stochastic('testVariable');
			samples = NaN;
			univariateObject.addSamples(samples);
			
			testCase.verifyEqual( univariateObject.mode, NaN )
		end
		
	end
end