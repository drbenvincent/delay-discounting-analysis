classdef test_allFilesInFolder < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function allFilesInFolder_1(testCase)
			results = allFilesInFolder(pwd, 'm');
			testCase.verifyTrue( iscellstr(results) )
		end
		
		function allFilesInFolder_2(testCase)
			path_to_test_data = fullfile(pwd,'..','demo','data');
			results = allFilesInFolder(path_to_test_data, 'txt');
			testCase.verifyTrue( iscellstr(results) )
			testCase.verifyLength( results, 15)
		end
		
	end
end

