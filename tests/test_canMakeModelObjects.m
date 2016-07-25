classdef test_canMakeModelObjects < matlab.unittest.TestCase
	
	properties
		data
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/data';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.data = DataClass(datapath, 'files', filesToAnalyse);
		end
	end
	
	
	methods (Test, TestTags = {'Unit'})
		
		function make_ModelHierarchicalME_MVNORM(testCase)
			model = ModelHierarchicalME_MVNORM(testCase.data);
			testCase.assertInstanceOf(model, 'ModelHierarchicalME_MVNORM')
		end
		
		function make_ModelHierarchicalME(testCase)
			model = ModelHierarchicalME(testCase.data);
			testCase.assertInstanceOf(model, 'ModelHierarchicalME')
		end
		
		function make_ModelHierarchicalMEUpdated(testCase)
			model = ModelHierarchicalMEUpdated(testCase.data);
			testCase.assertInstanceOf(model, 'ModelHierarchicalMEUpdated')
		end
		
		function make_ModelMixedME(testCase)
			model = ModelMixedME(testCase.data);
			testCase.assertInstanceOf(model, 'ModelMixedME')
		end
		
		function make_ModelSeparateME(testCase)
			model = ModelSeparateME(testCase.data);
			testCase.assertInstanceOf(model, 'ModelSeparateME')
		end
		
		function make_ModelMixedLogK(testCase)
			model = ModelMixedLogK(testCase.data);
			testCase.assertInstanceOf(model, 'ModelMixedLogK')
		end
		
		function make_ModelSeparateLogK(testCase)
			model = ModelSeparateLogK(testCase.data);
			testCase.assertInstanceOf(model, 'ModelSeparateLogK')
		end
		
		function make_ModelGaussianRandomWalkSimple(testCase)
			model = ModelGaussianRandomWalkSimple(testCase.data);
			testCase.assertInstanceOf(model, 'ModelGaussianRandomWalkSimple')
		end

		
	end
end

