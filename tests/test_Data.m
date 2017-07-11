classdef test_Data < matlab.unittest.TestCase
	
	properties
		data
		datapath
		filesToAnalyse
        metadata_location
	end
	
	properties (TestParameter)
		
	end
	
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			testCase.datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';
			
			testCase.filesToAnalyse = allFilesInFolder(testCase.datapath, 'txt');
			
			testCase.metadata_location = fullfile('demo','datasets',...
				'kirby','metadata','kirby-experiment-data.csv');
		
			%testCase.data = Data(testCase.datapath, 'files', testCase.filesToAnalyse);
		end
	end
	

	
	methods (Test)
		
% 		function createWithNoFiles(testCase)
% 			temp = Data(testCase.datapath);
% 			testCase.assumeClass(temp,'Data')
% 		end
		
% 		function create_then_load(testCase)
% 			temp = Data(testCase.datapath);
% 			temp = temp.importAllFiles({'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'});
% 		end

		function create_without_experiment_info(testCase)
			data = Data(testCase.datapath,...
				'files', testCase.filesToAnalyse);
		end
		
		function create_with_experiment_info_import_table(testCase)
            % metadata_location = fullfile('demo','datasets','test_data',...
            %     'kirby','metadata','kirby-experiment-data.csv')
			data = Data(testCase.datapath,...
				'files', testCase.filesToAnalyse,...
				'metaTableFile', testCase.metadata_location);
		end
		
		function create_with_experiment_info_provided_table(testCase)
			% build a Table. It must have row names equal to the filenames
			expTable = readtable(testCase.metadata_location);
			expTable.Properties.RowNames = expTable.filename;
			
			data = Data(testCase.datapath,...
				'files', testCase.filesToAnalyse,...
				'metaTable', expTable);
		end
		
		function get_proportion_delayed_responses(testCase)
			data = Data(testCase.datapath,...
				'files', testCase.filesToAnalyse);
			
			% get proportion of delayed responses chosen for all participants
			N = data.getNRealExperimentFiles();
			for n = 1:N
				scalar_proportion = data.getProportionDelayedOptionsChosen(n);
			end

		end
		
% 		function getIDnames_all(testCase)
% 			IDnames = testCase.data.getIDnames('all');
% 		end
% 		
% 		function getIDnames_participants(testCase)
% 			IDnames = testCase.data.getIDnames('experiments');
% 		end
% 	
% 		function getIDnames_unobserved(testCase)
% 			IDnames = testCase.data.getIDnames('unobserved');
% 		end
% 		
% 		function getIDnames_group(testCase)
% 			IDnames = testCase.data.getIDnames('group');
% 		end
% 		
% 		function getspecificIDname(testCase)
% 			IDnames = testCase.data.getIDnames(1);
% 		end
% 		
% 		function teardown(testCase)
% 	
% 		end
		
	end
	
end
