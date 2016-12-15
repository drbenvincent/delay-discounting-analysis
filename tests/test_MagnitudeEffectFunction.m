classdef test_MagnitudeEffectFunction < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function scalar_input(testCase)
			
			
			% evaluate with these paraams
			m = 0;
			c = randn*10;
			expected_answer = []; % ??????
			
			reward_magnitide = 100;
			
			% construct discount function object
			my_func = MagnitudeEffectFunction('samples', struct('m', m, 'c', c) );
			
			testCase.verifyEqual(...
				my_func.eval(reward_magnitide),...
				expected_answer,...
				'RelTol', 0.0001)

			
		end
		
	end
end