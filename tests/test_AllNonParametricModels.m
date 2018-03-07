classdef test_AllNonParametricModels < matlab.unittest.TestCase
	% test that we can instantiate all of the specified model classes. This
	% uses Matlab's Parameterized Testing:
	% http://uk.mathworks.com/help/matlab/matlab_prog/create-basic-parameterized-test.html
	% So we don't have to laborously write down test methods for all the
	% model class types.

	properties
		data
		saveName = 'temp.mat'
		savePath = tempname(); % matlab auto-generated temp folders
	end

	properties (TestParameter)
		model = {'ModelSeparateNonParametric'}
		pointEstimateType = {'mean','median','mode'}
		chains = {2,3,4}
	end


	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------

	methods (TestClassSetup)
		function setupData(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non_parametric';

			% only analyse 2 people, for speed of running tests
			filesToAnalyse = allFilesInFolder(datapath, 'txt');
			filesToAnalyse = filesToAnalyse(1:2);
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
	end

	methods(TestClassTeardown)
		function remove_temp_folder(testCase)
			rmdir(testCase.savePath,'s')
		end
		function on_exit(testCase)
			delete('temp.mat')
		end
		function close_figs(testCase)
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
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests()),...
				'shouldPlot','no',...
				'shouldExport',false);
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end

		function nChains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', chains,...
				'nburnin', get_burnin_for_tests()),...
				'shouldPlot','no');

			% removed this because I've removed get_nChains. It was an
			% uncessary public method
			%testCase.verifyEqual(chains, model.get_nChains())
		end


		function plotting(testCase, model)
			% make model
			makeModelFunction = str2func(model);

			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests()),...
				'shouldPlot','yes',...
				'shouldExport',false);
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end

		function model_disp_function(testCase, model)
			% make model
			makeModelFunction = str2func(model);
			modelFitted = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests()),...
				'shouldPlot','no');
			% Can we call the disp function without error?
			disp(modelFitted)
		end

	end

end
