classdef test_PlotAllModels < matlab.unittest.TestCase

	properties
		data
		savePath = tempname(); % matlab auto-generated temp folders
	end

	properties (TestParameter)
		model = getAllParametricModelNames;
		pointEstimateType = {'mean','median','mode'};
		dataset = {'kirby', 'non_parametric'};
		chains = {2,3}
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
% 	methods (TestClassSetup)
% 		function setup(testCase)
% 		end
% 	end


	methods(TestClassTeardown)

		function remove_temp_directory(testCase)
			rmdir(testCase.savePath,'s')
		end

		function close_figures(testCase)
			close all
		end

	end


	%% THE ACTUAL TESTS ---------------------------------------------------

	methods (Test)

		function plot(testCase, model, dataset)

			%% Set up data
			datapath = ['~/git-local/delay-discounting-analysis/demo/datasets/' dataset];
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			% only analyse 2 people, for speed of running tests
			filesToAnalyse = allFilesInFolder(datapath, 'txt');
			filesToAnalyse = filesToAnalyse(1:2);
			testCase.data = Data(datapath, 'files', filesToAnalyse);

			%% Run model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'shouldPlot','yes',...
				'shouldExportPlots', false,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests() ));
			%model.plot();

			close all
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end

	end

end
