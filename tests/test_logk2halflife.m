classdef test_logk2halflife < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function testlogk2halflife1(testCase)
			testCase.verifyEqual( logk2halflife(log(1/100)), 100, 'AbsTol', 10^-5)
		end
	
		function testlogk2halflife2(testCase)
			testCase.verifyEqual( logk2halflife(log(1/50)), 50, 'AbsTol', 10^-5)
		end
		
	end
end

