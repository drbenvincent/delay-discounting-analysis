classdef test_AllParametricModels < matlab.unittest.TestCase
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
		sampler = {'jags', 'stan'} % TODO: ADD STAN
		model = {'ModelHierarchicalME_MVNORM',...
			'ModelHierarchicalME', 'ModelHierarchicalMEUpdated',...
			'ModelMixedME', 'ModelSeparateME',...
			'ModelHierarchicalLogK', 'ModelMixedLogK', 'ModelSeparateLogK',...
			'ModelHierarchicalExp1', 'ModelMixedExp1', 'ModelSeparateExp1'}
		pointEstimateType = {'mean','median','mode'}
		chains = {2,3,4}
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
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

		function defaultSampler(testCase, model)
			% make model
			makeModelFunction = str2func(model);

			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', 10^2,...
									 'nchains', 2,...
									 'nburnin', 50),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end

		function nChains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);

			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', 10^2,...
									 'nchains', chains,...
									 'nburnin', 50),...
				'shouldPlot','no');

			testCase.verifyEqual(chains, model.get_nChains())
		end


		function specifiedSampler(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'sampler', sampler,...
				'mcmcParams', struct('nsamples', 100,...
									 'nchains', 2,...
									 'nburnin', 10),...
				'shouldPlot','no');

			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
		
		function getting_predicted_values(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'sampler', sampler,...
				'mcmcParams', struct('nsamples', 100,...
								'nchains', 2,...
								'nburnin', 10),...
								'shouldPlot','no');
			
			% Get inferred present subjective values of
			[predicted_subjective_values] =...
				model.get_inferred_present_subjective_values();

			testCase.assertTrue(isstruct(predicted_subjective_values))
			% tests for point estimates
			testCase.assertTrue(istable(predicted_subjective_values.point_estimates))
% 			% tests for full distributions
%  			testCase.assertTrue(ismatrix(predicted_subjective_values.A_full_posterior))
%  			testCase.assertTrue(ismatrix(predicted_subjective_values.B_full_posterior))
			
		end
		

	end

end
