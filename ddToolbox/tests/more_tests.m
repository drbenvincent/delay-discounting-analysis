classdef more_tests < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test)
		
		function testlogk2halflife1(testCase)
			testCase.verifyEqual( logk2halflife(log(1/100)), 100, 'AbsTol', 10^-5)
		end
	
		function testlogk2halflife2(testCase)
			testCase.verifyEqual( logk2halflife(log(1/100)), 100, 'AbsTol', 10^-5)
		end
		
	end
end

