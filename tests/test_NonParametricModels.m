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
		model = {'ModelGRW'}
		pointEstimateType = {'mean','median','mode'}
		sampler = {'jags', 'stan'} % TODO: ADD STAN
		chains = {2,3}
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'CA-gain.txt', 'RG-loss.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
	end
	
	
% 	methods (Test, TestTags = {'Unit'})
% 		
% 		function make_model_zeroArguments(testCase, model)
% 			makeModelFunction = str2func(model);
% 			created_model = makeModelFunction(testCase.data);
% 			testCase.assertInstanceOf(created_model, model)
% 		end
% 			
% 		function make_model_withPointEstimateType(testCase, model, pointEstimateType)
% 			makeModelFunction = str2func(model);
% 			created_model = makeModelFunction(testCase.data,...
% 				'pointEstimateType', pointEstimateType);
% 			testCase.assertInstanceOf(created_model, model)
% 		end
% 		
% 	end
	
	methods (Test)
		
		function doInferenceWithModel_default_sampler(testCase, model)
			% make model
			makeModelFunction = str2func(model);

			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'mcmcParams', struct('nsamples', 10^2,...
									 'chains', 2,...
									 'nburnin', 100),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		% TODO
% 		function singleChainRequestedShouldError(testCase)
% 			
% 			testCase.assertError
% 		end
		
		function doInferenceWithModel_with_N_chains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);
			
			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'mcmcParams', struct('nsamples', 10^2,...
									'chains', 2,...
									'nburnin', 100),...
				'shouldPlot','no');
			
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function doInferenceWithModel_specified_sampler(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'sampler', sampler,...
				'shouldPlot','no',...
				'mcmcParams', struct('nsamples', 10^2,...
									 'chains', 2,...
									 'nburnin', 100));
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		function does_plotting_work(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'sampler', sampler,...
				'mcmcParams', struct('nsamples', 100,...
				'chains', 2,...
				'nburnin', 100),...
				'shouldPlot','no');
			model.plot('shouldExportPlots', false);
			
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function teardown(testCase)
			% we are in the tests folder
			rmdir('figs','s')
			delete('*.R')
			delete('*.csv')
		end
		
	end
	
end

