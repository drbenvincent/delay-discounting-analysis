classdef test_magnitudeEffect < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test_scalar_input(testCase)
			m = 0;
			c = randn*10;
			k = magnitudeEffect(100, [m c]);
			
			testCase.verifyEqual( log(k), c, 'RelTol', 0.001)
			
		end
		
	end
end