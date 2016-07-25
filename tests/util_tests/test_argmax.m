classdef test_argmax < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test)
		
		function testargmax1(testCase)
			testCase.verifyEqual( argmax([1 1 1 2]) , 4)
		end
		
	end
end

