classdef test_DataInputs < matlab.unittest.TestCase
	% Test import of data from files with possible errors, or atypical
	% examples
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
		end
	end
	

	
	methods (Test)
		
		function missing_responses(testCase)
			testCase.data = Data(testCase.datapath, 'files', {'missing_responses.txt'});
			data = testCase.data.getExperimentData(1);
			testCase.assertEqual(sum(isnan(data.R)~=0), 0);
		end
		
		function missing_correct_total_trials(testCase)
			testCase.data = Data(testCase.datapath, 'files', {'missing_responses.txt'});
			data = testCase.data.getExperimentData(1);
			testCase.assertEqual(data.trialsForThisParticant, numel(data.R))
		end
		
		function frontend_mix(testCase)
			testCase.data = Data(testCase.datapath, 'files', {'frontend_mix.txt'});
		end
		
		function frontend(testCase)
			testCase.data = Data(testCase.datapath, 'files', {'frontend.txt'});
		end
		
		function incorrect_responses(testCase)
			noError = false;
			expected_error_message = 'Data:AssertionFailed';
			try
				Data(testCase.datapath, 'files', {'incorrect_responses.txt'})
				noError=true;
			catch actualME
				testCase.assertEqual(actualME.identifier, expected_error_message)
				
			end
			testCase.verifyFalse(noError, 'This test should fail, but it didn''t)')
		end
		
		function column_order(testCase)
			testCase.data = Data(testCase.datapath, 'files', {'different_column_order.txt'});
			
			model = ModelSeparateLogK(testCase.data,...
				'savePath', tempname(),...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
				'nchains', 2,...
				'nburnin', get_burnin_for_tests()),...
				'shouldPlot','no');
		end
		
		
	end
	
end

