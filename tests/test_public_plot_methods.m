classdef test_public_plot_methods < matlab.unittest.TestCase

	properties
		data
		model
		savePath = tempname(); % matlab auto-generated temp folders
	end

	properties (TestParameter)
		% 		% just test with a couple of selected models
		% 		%model = {'ModelHierarchicalME', 'ModelHierarchicalLogK', 'ModelSeparateNonParametric'};
		% 		model = {'ModelHierarchicalME'};
		% 		dataset = {'non_parametric'};
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setup(testCase)

			model = 'ModelHierarchicalLogK';
			dataset = 'non_parametric';

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
			testCase.model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'shouldPlot', 'no',...
				'shouldExportPlots', false,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests() ));
		end
	end


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

		function plotDiscountFunction(testCase)
			expt_to_plot = 1;
			testCase.model.plotDiscountFunction(expt_to_plot);
			close all
		end

		function plotDiscountFunctionGrid(testCase)
			testCase.model.plotDiscountFunctionGrid();
			close all
		end

		function plotDiscountFunctionsOverlaid(testCase)
			testCase.model.plotDiscountFunctionsOverlaid();
			close all
		end

		function plotPosteriorAUC(testCase)
			expt_to_plot = 1;
			testCase.model.plotPosteriorAUC(expt_to_plot);
			close all
		end

		function plotPosteriorClusterPlot(testCase)
			testCase.model.plotPosteriorClusterPlot();
			close all
		end

		function plotUnivarateSummary(testCase)
			testCase.model.plotUnivarateSummary();
			close all
		end
	end

end
