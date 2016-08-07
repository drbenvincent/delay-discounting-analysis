classdef test_excludeThese < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test1(testCase)
			fnames = {'apple', 'bananna', 'cucumber', 'dog', 'spatula'};
			exclude = {'dog', 'spatula'};
			result = excludeThese(fnames, exclude);
			testCase.verifyTrue( numel(result)==3 )
		end
		
		function test2(testCase)
			fnames = {'apple', 'bananna', 'cucumber', 'dog', 'spatula'};
			exclude = {};
			result = excludeThese(fnames, exclude);
			testCase.verifyTrue( numel(result)==5 )
		end
		
		
	end
end