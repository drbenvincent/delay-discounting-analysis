classdef test_ModelHierarchicalME < matlab.unittest.TestCase
	% Test the example code (run_me.m) I've provided to demonstrate using the
	% software.
	
	properties
		data
		model
		mcmcSamples = 10^2
		chains = 2
		tempSaveName = 'temp.mat'
	end
	
	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setupData(testCase)
			% assuming this is running on my maching
			%addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
		
		function setupModel(testCase)
			% so we can re-use it without having to fit again
			testCase.model = ModelHierarchicalME(testCase.data,...
				'mcmcParams', struct('nsamples', 10^2,...
				'chains', 2,...
				'nburnin', 100),...
				'shouldPlot','no');
		end
	end
	
	methods(TestClassTeardown)
		function onexit(testCase)
			% we are in the tests folder
			rmdir('figs','s')
			delete('temp.mat')
			close all
		end
	end
	
	
	
	%% THE ACTUAL TESTS ---------------------------------------------------
	
	
	methods (Test)
		
% 		function fitHierarchicalME(testCase)
% 			model = ModelHierarchicalME(testCase.data,...
% 				'savePath', 'unit test output',...
% 				'mcmcParams', struct('nsamples', 10^2,...
% 				'chains', 2,...
% 				'nburnin', 100),...
% 				'shouldPlot','no');
% 			testCase.assertInstanceOf(model,'ModelHierarchicalME')
% 		end
		
		
		function hypothesisTestDemo(testCase)
			% have to ensure demo folder is on path
			addpath('demo') % assuming we are in the project root
			hypothesisTestScript( testCase.model )
		end
		
		
		function SaveAndLoad(testCase)
			model = testCase.model;
			% save it
			save(testCase.tempSaveName, 'model')
			clear model
			load(testCase.tempSaveName)
			% tests
			testCase.assertInstanceOf(model,'ModelHierarchicalME')
		end
		
		
		function canGetSamples(testCase)
			samples = testCase.model.coda.getSamples({'m','c','alpha','epsilon'});
			testCase.assumeTrue(isstruct(samples))
		end
		
		
		function coda_plot_chains(testCase)
			testCase.model.coda.trellisplots({'m'})
		end
		
		function coda_plot_mulitple_chains(testCase)
			testCase.model.coda.trellisplots({'m', 'c'})
		end
		
	end
end

