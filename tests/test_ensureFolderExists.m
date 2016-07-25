classdef test_ensureFolderExists < matlab.unittest.TestCase
	
	properties
	end
	
	methods (Test, TestTags = {'Unit'})
		
		function ensureFolderExists_nonexistant(testCase)
			testFolderToMake = 'thisFolderDoesNotExist';
			results = ensureFolderExists(testFolderToMake);
			sucess = (exist(testFolderToMake,'dir')==7);
			testCase.verifyTrue(sucess)
			testCase.verifyTrue(results)
			rmdir(testFolderToMake)
		end
		
		function ensureFolderExists_existant(testCase)
			current_location = pwd;
			results = ensureFolderExists(current_location);
			testCase.verifyTrue(results)
		end
		
		
	end
end

