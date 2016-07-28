classdef test_NonParametricModels < matlab.unittest.TestCase
	% test that we can instantiate all of the specified model classes. This
	% uses Matlab's Parameterized Testing:
	% http://uk.mathworks.com/help/matlab/matlab_prog/create-basic-parameterized-test.html
	% So we don't have to laborously write down test methods for all the
	% model class types.
	
	properties
		data
	end
	
	properties (TestParameter)
		model = {'ModelGaussianRandomWalkSimple'}
		pointEstimateType = {'mean','median','mode'}
		sampler = {'jags'} % TODO: ADD STAN
		chains = {1,2,3}
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'CA-gain.txt', 'RG-loss.txt'};
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
		
		function doInferenceWithModel_default_sampler(testCase, model)
			% make model
			makeModelFunction = str2func(model);
			created_model = makeModelFunction(testCase.data);
			% do inference with model
			created_model = created_model.conductInference(...
				'mcmcSamples', 100,...
				'chains', 2,...
				'shouldPlot', 'no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		function doInferenceWithModel_with_N_chains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);
			created_model = makeModelFunction(testCase.data);
			% do inference with model
			created_model = created_model.conductInference(...
				'mcmcSamples', 100,...
				'chains', chains,...
				'shouldPlot', 'no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function doInferenceWithModel_specified_sampler(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			saveFolderName = model;
			created_model = makeModelFunction(testCase.data,...
				'saveFolder', saveFolderName);
			% do inference with model
			created_model = created_model.conductInference(...
				'sampler', sampler,...
				'mcmcSamples', 100,...
				'chains', 2,...
				'shouldPlot', 'no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function teardown(testCase)
			% we are in the tests folder
			rmdir('figs','s')
		end
		
	end
	
end

