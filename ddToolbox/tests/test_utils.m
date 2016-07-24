classdef test_utils < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test)
		
		function testPrefix1(testCase)
			testCase.verifyEqual( getPrefixOfString('bv-kirby27.txt', '-'), 'bv')
		end
	
		function testargmax1(testCase)
			testCase.verifyEqual( argmax([1 1 1 2]) , 4)
		end
		
	end
end

