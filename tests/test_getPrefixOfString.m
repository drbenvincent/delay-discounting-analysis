classdef test_getPrefixOfString < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test1(testCase)
			testCase.verifyEqual( getPrefixOfString('bv-kirby27.txt', '-'), 'bv')
		end
		
	end
end

