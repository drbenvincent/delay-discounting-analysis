classdef test_vec < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test_empty_input(testCase)
			testCase.verifyTrue( iscolumn( vec([])) )
		end
		
		function test_row(testCase)
			rowinput = vec(ones(1,10));
			testCase.verifyTrue( iscolumn(rowinput) )
		end
		
		function test_col(testCase)
			colinput = vec(ones(10,1));
			testCase.verifyTrue( iscolumn(colinput) )
		end
		
		function test_2d(testCase)
			matrix = vec(rand(10));
			testCase.verifyTrue( iscolumn(matrix) )
		end
		
% 		function test_struct_input(testCase)
% 			my_struct = struct('a', 10, 'b', 20);
% 			vec(my_struct)
% 		end
		
	end
end