classdef test_ModelGRW < matlab.unittest.TestCase
% Test the example code (run_me.m) I've provided to demonstrate using the
% software.

	properties
		data
		%mcmcSamples = 10^4
		%chains = 2
		tempSaveName = 'temp.mat'
		model
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my machine
			%addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';
			
			filesToAnalyse={'BD1.txt', 'BD2.txt', 'BD3.txt', 'BD4.txt', 'BD5.txt', 'BD6.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
	end
	
	methods (Test)
		
		function fit(testCase)
			
			testCase.assertInstanceOf(testCase.data,'Data')
			
			testCase.model = ModelGRW(testCase.data,...
				'savePath', 'tests/grw_test',...
				'shouldPlot','no',...
				'mcmcParams', struct('nsamples', 10^3,...
									'chains', 2,...
									'nburnin', 100));
		end
		
		
		function plot(testCase)
			testCase.model.plot('shouldExportPlots', true)
		end
		
		
		
% 		function teardown(testCase)
% 			% we are in the tests folder
% 			rmdir('figs','s')
% 			delete(testCase.tempSaveName)
% 		end
		
	end
end

