classdef test_demo_group_comparison < matlab.unittest.TestCase
	
	properties
	end
	
	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setup(testCase)

		end
	end
	
	%% THE ACTUAL TESTS ---------------------------------------------------
	
	methods (Test)
		function does_demo_run(testCase)
			
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/demo')
			
			% TODO: Do dependency injection... inject in the parameters so
			% we can run it quickly
			demo_group_comparison()
			
			% TODO: do more meaningful tests here. All this does is check
			% to see if the code errors or not
		end
	end
end
