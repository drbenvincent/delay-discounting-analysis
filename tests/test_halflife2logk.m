classdef test_halflife2logk < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function test1(testCase)
			halflife = 50;
			logk = halflife2logk(halflife);
			
			testCase.verifyEqual( exp(logk), 1/halflife, 'RelTol', 0.001)
		end
		
		function test_mistake1(testCase)
			halflife = 50;
			logk = halflife2logk(halflife);
			testCase.verifyNotEqual( exp(logk), halflife)
		end
		
		function test_mistake2(testCase)
			halflife = 50;
			logk = halflife2logk(halflife);
			testCase.verifyNotEqual( logk, 1/halflife)
		end
		
		function test_halflifeZero(testCase)
			halflife = 0;
			logk = halflife2logk(halflife);
			testCase.verifyTrue( isinf(logk) )
		end
		
	end
end