classdef test_create_subplots < matlab.unittest.TestCase
	
	properties
		TestFigure
	end
	
	properties (TestParameter)
		N = {1,2,3,4,5}
		facetStyle = {'row','col'}
	end
	
	
	methods(TestMethodSetup)
		function createFigure(testCase)
			% comment
			testCase.TestFigure = figure;
		end
	end
	
	methods(TestMethodTeardown)
		function closeFigure(testCase)
			close(testCase.TestFigure)
		end
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function correct_output_length(testCase, N, facetStyle)
			subplot_handles = create_subplots(N, facetStyle);
			testCase.verifyTrue( numel(subplot_handles)==N )
			clf
		end
		
	end
end