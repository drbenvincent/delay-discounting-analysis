classdef test_AllParametricModels < matlab.unittest.TestCase
	% test that we can instantiate all of the specified model classes. This
	% uses Matlab's Parameterized Testing:
	% http://uk.mathworks.com/help/matlab/matlab_prog/create-basic-parameterized-test.html
	% So we don't have to laborously write down test methods for all the
	% model class types.
	
	properties
		data
	end
	
	properties (TestParameter)
		sampler = {'jags', 'stan'} % TODO: ADD STAN
		model = {'ModelHierarchicalME_MVNORM',...
			'ModelHierarchicalME',... 
			'ModelHierarchicalMEUpdated',... 
			'ModelMixedME',...
			'ModelSeparateME',... 
			'ModelHierarchicalLogK',...
			'ModelMixedLogK',...
			'ModelSeparateLogK',...
			'ModelGaussianRandomWalkSimple'}
		pointEstimateType = {'mean','median','mode'}
		chains = {2,3}
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
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
			
			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'mcmcParams', struct('nsamples', 10^2,...
									 'chains', 2,...
									 'nburnin', 100),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		function doInferenceWithModel_with_N_chains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);
			
			model = makeModelFunction(testCase.data,...
				'saveFolder', 'unit test output',...
				'mcmcParams', struct('nsamples', 10^2,...
									 'chains', chains,...
									 'nburnin', 100),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function doInferenceWithModel_specified_sampler(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			saveFolderName = model;
			chains = 2;
			model = makeModelFunction(testCase.data,...
				'saveFolder', saveFolderName,...
				'mcmcParams', struct('nsamples', 10^2,...
									 'chains', chains,...
									 'nburnin', 100),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		% 		function canCompileSTANmodel(testCase, model)
		% 			% make model
		% 			makeModelFunction = str2func(model);
		% 			saveFolderName = model;
		% 			created_model = makeModelFunction(testCase.data,...
		% 				'saveFolder', saveFolderName);
		%
		% 			% Try to compile stan model
		% 			stan_model = StanModel('file', created_model.modelFilename,...
		% 				'stan_home', obj.stanHome);
		% 			% Compile the Stan model. This takes a bit of time
		% 			display(['COMPILING STAN MODEL...' model])
		% 			stan_model.compile();
		%
		% 		end
		
		function teardown(testCase)
			% we are in the tests folder
			rmdir('figs','s')
			delete('*.R')
			delete('*.csv')
		end
		
	end
	
end

