classdef test_renameFields < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test1(testCase)
			initial = struct('a',1, 'b', 2);
			results = renameFields(initial, {'a', 'b'}, {'c', 'd'});
			
			testCase.verifyFalse( isfield(results,'a') )
			testCase.verifyFalse( isfield(results,'b') )
			
			testCase.verifyTrue( isfield(results,'c') )
			testCase.verifyTrue( isfield(results,'d') )
			
			testCase.verifyTrue( results.c == 1 )
			testCase.verifyTrue( results.d == 2 )
			
		end
		
	end
end

