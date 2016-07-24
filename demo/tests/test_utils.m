classdef test_utils < matlab.unittest.TestCase
	
	properties
		myData
		mcmcSamples = 10^2
		chains = 2
	end
	
	methods (TestClassSetup)
		function loadData(testCase)
			datapath = '~/git-local/delay-discounting-analysis/demo/data';
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.myData = DataClass(datapath, 'files', filesToAnalyse);
		end
	end
	
	methods (Test)
		
		function testModelHierarchicalME_MVNORM_JAGS(testCase)
			model = ModelHierarchicalME_MVNORM(testCase.myData,...
				'saveFolder', 'mvnorm test',...
				'pointEstimateType','mode');
			model = model.conductInference(...
				'jags',...
				'mcmcSamples', testCase.mcmcSamples,...
				'chains',testCase.chains,...
				'shouldPlot','no');
				
			testCase.assertInstanceOf(model,'ModelHierarchicalME_MVNORM')
		end
		
	end
end

