classdef test_calcDataLikelihood < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test_scalar_input1(testCase)
			responses = [1];
			predicted = 0.5;
			dataLikelihood = calcDataLikelihood(responses, predicted);
			testCase.verifyEqual( dataLikelihood, 0.5, 'RelTol', 0.001)
		end
		
		function test_input2(testCase)
			% not convinced that we will ever have a <vector, scalar> input
			responses = [1 0 1 0];
			predicted = 0.5;
			dataLikelihood = calcDataLikelihood(responses, predicted);
			testCase.verifyEqual( dataLikelihood, prod([0.5 0.5 0.5 0.5]), 'RelTol', 0.001)
		end
		
		function test_input3(testCase)
			responses = [1 0 1 0];
			predicted = [0.5 0.5 0.5 0.5];
			dataLikelihood = calcDataLikelihood(responses, predicted);
			testCase.verifyEqual( dataLikelihood, prod([0.5 0.5 0.5 0.5]), 'RelTol', 0.001)
		end
		
	end
end