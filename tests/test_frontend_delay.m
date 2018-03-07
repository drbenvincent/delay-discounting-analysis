classdef test_frontend_delay < matlab.unittest.TestCase

	properties
		data
		datapath
		filesToAnalyse
	end

	properties (TestParameter)

	end

	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			testCase.datapath = '~/git-local/delay-discounting-analysis/demo/datasets/test_data';
			testCase.data = Data(testCase.datapath, 'files', {'fe1.txt', 'fe2.txt', 'fe3.txt', 'fe4.txt'});
		end
	end



	methods (Test)

		function analysis_of_front_end_delay(testCase)
			% Do an analysis
			model = ModelHierarchicalLogK(...
				testCase.data,...
				'savePath', fullfile(pwd,'output','my_analysis'),...
				'pointEstimateType', 'median',...
				'shouldPlot', 'no',...
				'shouldExportPlots', false,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests()));
		end

	end

end
