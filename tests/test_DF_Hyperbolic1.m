classdef test_DF_Hyperbolic1 < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function scalarInput(testCase)
			
			% evaluate with these paraams
			logk	= 1/365;
			delay	= 365;
			expected_discount_fraction = 0.5;
			
			% construct discount function object
			my_func = DF_Hyperbolic1('samples', struct('logk', logk) );
			
			testCase.verifyEqual(...
				my_func.eval(delay),...
				expected_discount_fraction,...
				'RelTol', 0.0001)
			
		end
		
	end
end