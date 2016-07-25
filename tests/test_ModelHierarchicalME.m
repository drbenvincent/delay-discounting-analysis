classdef test_ModelHierarchicalME < matlab.unittest.TestCase
% Test the example code (run_me.m) I've provided to demonstrate using the
% software.

	properties
		data
		%model
		mcmcSamples = 10^2
		chains = 2
		tempSaveName = 'temp.mat'
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			%addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/data';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.data = DataClass(datapath, 'files', filesToAnalyse);
		end
	end
	
	methods (Test)
		
		function defaultInferenceWithModelHierarchicalME(testCase)
			
			testCase.assertInstanceOf(testCase.data,'DataClass')
			
			model = ModelHierarchicalME(testCase.data,...
				'saveFolder', 'unit test output');
			model = model.conductInference(...
				'mcmcSamples', testCase.mcmcSamples,...
				'chains',testCase.chains,...
				'shouldPlot','no');
			testCase.assertInstanceOf(model,'ModelHierarchicalME')
		end
		
		function SaveAndLoad(testCase)
			% pre-loaded data
			data = testCase.data;
			% create new model
			model = ModelHierarchicalME(testCase.data,...
				'saveFolder', 'unit test output');
			% don't bother converging it
			% save it
			save(testCase.tempSaveName, 'data', 'model')
			clear model data
			load(testCase.tempSaveName)
			% tests
			testCase.assertInstanceOf(model,'ModelHierarchicalME')
			testCase.assertInstanceOf(data,'DataClass')
		end
		
		function canGetSamples(testCase)
			% create new model
			model = ModelHierarchicalME(testCase.data,...
				'saveFolder', 'unit test output');
			model = model.conductInference(...
				'mcmcSamples', testCase.mcmcSamples,...
				'chains',testCase.chains,...
				'shouldPlot','no');
			samples = model.mcmc.getSamples({'m','c','alpha','epsilon'});
			testCase.assumeTrue(isstruct(samples))
		end
		
	end
end

