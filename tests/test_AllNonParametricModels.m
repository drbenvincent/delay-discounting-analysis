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
		sampler = {'jags', 'stan'} % TODO: ADD STAN
		chains = {2,3,4}
	end
	
	
	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	
	methods (TestClassSetup)
		function setupData(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/non-parametric';
			
			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'CA-gain.txt', 'RG-loss.txt'};
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
				'mcmcParams', struct('nsamples', 10^2,...
				'nchains', 2,...
				'nburnin', 100),...
				'shouldPlot','no');
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
			
			model.plot('shouldExportPlots', true)
		end
		
		function nChains(testCase, model, chains)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'mcmcParams', struct('nsamples', 10^2,...
				'nchains', chains,...
				'nburnin', 100),...
				'shouldPlot','no');
			
			testCase.verifyEqual(chains, model.get_nChains())
		end
		
		
		function specifiedSampler(testCase, model, sampler)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'sampler', sampler,...
				'shouldPlot','no',...
				'mcmcParams', struct('nsamples', 10^2,...
				'nchains', 2,...
				'nburnin', 100));
			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end
		
	end
	
end

