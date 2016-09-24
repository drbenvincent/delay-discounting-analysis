classdef test_calculateAUC < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function calculateAUC_1(testCase)
			results = calculateAUC([0 1],[1 0], false);
			testCase.verifyEqual( results, 0.5 , 'AbsTol', 10^-5)
		end
		
		function calculateAUC_2(testCase)
			results = calculateAUC([0 1]*5,[1 0], false);
			testCase.verifyEqual( results, 0.5 , 'AbsTol', 10^-5)
		end
		
		function calculateAUC_3(testCase)
			results = calculateAUC([0 1]*5,[1 1], false);
			testCase.verifyEqual( results, 1 , 'AbsTol', 10^-5)
		end
		
		
	end
end

