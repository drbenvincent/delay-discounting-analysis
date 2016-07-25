classdef test_AllModels < matlab.unittest.TestCase
	% test that we can instantiate all of the specified model classes. This
	% uses Matlab's Parameterized Testing:
	% http://uk.mathworks.com/help/matlab/matlab_prog/create-basic-parameterized-test.html
	% So we don't have to laborously write down test methods for all the
	% model class types.
	
	properties
		data
	end
	
	properties (TestParameter)
		model = {'ModelHierarchicalME_MVNORM',...
			'ModelHierarchicalME',...
			'ModelHierarchicalMEUpdated',...
			'ModelMixedME',...
			'ModelSeparateME',...
			'ModelHierarchicalLogK',...
			'ModelMixedLogK',...
			'ModelSeparateLogK',...
			'ModelGaussianRandomWalkSimple'};
		pointEstimateType = {'mean','median','mode'}
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
		
		function make_model_zeroArguments(testCase, model)
			makeModelFunction = str2func(model);
			created_model = makeModelFunction(testCase.data);
			testCase.assertInstanceOf(created_model, model)
		end
			
		function make_model_withPointEstimateType(testCase, model, pointEstimateType)
			makeModelFunction = str2func(model);
			created_model = makeModelFunction(testCase.data,...
				'pointEstimateType', pointEstimateType);
			testCase.assertInstanceOf(created_model, model)
		end
		
	end
	
	methods (Test)
		
% 		function doInferenceWithModel(testCase, model)
% 			% make model
% 			makeModelFunction = str2func(model);
% 			created_model = makeModelFunction(testCase.data);
% 			% do inference with model
% 			created_model = created_model.conductInference(...
% 				'mcmcSamples', 100,...
% 				'chains', 1,...
% 				'shouldPlot', 'no');
% 			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
% 		end
		
	end
	
end

