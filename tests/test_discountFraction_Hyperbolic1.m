classdef test_discountFraction_Hyperbolic1 < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function scalarInput(testCase)
			
			k		= 1/365;
			delay	= 365;
			df = discountFraction_Hyperbolic1(k,delay);
			
			testCase.verifyEqual( df, 0.5, 'RelTol', 0.0001)
			
		end
		
	end
end