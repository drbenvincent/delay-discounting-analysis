classdef test_EXP_POWER_models < matlab.unittest.TestCase
	% test that we can instantiate all of the specified model classes. This
	% uses Matlab's Parameterized Testing:
	% http://uk.mathworks.com/help/matlab/matlab_prog/create-basic-parameterized-test.html
	% So we don't have to laborously write down test methods for all the
	% model class types.

	properties
		data
		savePath = tempname(); % matlab auto-generated temp folders
	end

	properties (TestParameter)
		model_list = {'ModelSeparateExpPower',...
			'ModelMixedExpPower',...
			'ModelHierarchicalExpPower'};
		sampler = {'jags'};
		pointEstimateType = {'mean'}; %{'mean','median','mode'}
		chains = {2}
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';

			% only analyse 2 people, for speed of running tests
			filesToAnalyse = allFilesInFolder(datapath, 'txt');
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
	end


	methods(TestClassTeardown)

		function remove_temp_directory(testCase)
			rmdir(testCase.savePath,'s')
		end

		function delete_stan_related_outputs(testCase)
			delete('*.data.R')
			delete('*.csv')
		end

		function close_figures(testCase)
			close all
		end

	end


	%% THE ACTUAL TESTS ---------------------------------------------------

	methods (Test)
				
		function does_model_run_to_completion(testCase, model_list, sampler)
			% make model
			makeModelFunction = str2func(model_list);
			modelFitted = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'sampler', sampler,...
				'mcmcParams', struct('nsamples', 50,...
								'nchains', 2,...
								'nburnin', 10),...
								'shouldPlot','no');
% 			
% 			% Get inferred present subjective values of
% 			[predicted_subjective_values] =...
% 				modelFitted.get_inferred_present_subjective_values();
% 
% 			testCase.assertTrue(isstruct(predicted_subjective_values))
		end
		
	end

end
