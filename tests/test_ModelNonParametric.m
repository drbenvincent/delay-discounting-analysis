classdef test_ModelSeparateNonParametric < matlab.unittest.TestCase
	% Test the example code (run_me.m) I've provided to demonstrate using the
	% software.

	properties
		data
		%mcmcSamples = 10^4
		%chains = 2
		%tempSaveName = 'temp.mat'
		model
		savePath = tempname(); % matlab auto-generated temp folders
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------

	methods (TestClassSetup)
		function setupData(testCase)
			% assuming this is running on my machine
			%addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';

			filesToAnalyse={'BD1.txt', 'BD2.txt', 'BD3.txt', 'BD4.txt', 'BD5.txt', 'BD6.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end

	end

	methods(TestClassTeardown)
		function remove_temp_folder(testCase)
			rmdir(testCase.savePath,'s')
		end
		% 		function on_exit(testCase)
		% 			delete('temp.mat')
		% 		end
		function close_figs(testCase)
			close all
		end
	end


	%% THE ACTUAL TESTS ---------------------------------------------------


	methods (Test)
		
		function fitModel(testCase)
			testCase.model = ModelSeparateNonParametric(testCase.data,...
				'savePath', testCase.savePath,...
				'shouldPlot','no',...
				'mcmcParams', struct('nsamples', 10^3,...
				'nchains', 4,...
				'nburnin', 1000));
			
			testCase.model.plot('shouldExportPlots', true)
		end
		
	end
end
