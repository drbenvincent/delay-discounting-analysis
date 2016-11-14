classdef test_myExport < matlab.unittest.TestCase

	properties
		figHandle
		folder
	end
	
	properties (TestParameter)
		format = {'png'}
	end
	
	
	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setup(testCase)
			testCase.figHandle = figure;
			plot(rand(10));
			drawnow
			testCase.folder = 'tests/temp';
			ensureFolderExists(testCase.folder)
		end
	end
	
	methods(TestClassTeardown)
		function closeFigure(testCase)
			close(testCase.figHandle)
		end
		
		function removeTempDir(testCase)
			rmdir(testCase.folder,'s')
		end
	end
	
	
	%% METHOD-LEVEL SETUP/TEARDOWN ----------------------------------------
	methods (TestMethodSetup)

	end
	
	methods(TestMethodTeardown)

	end
	

	%% THE ACTUAL TESTS ---------------------------------------------------
	
	methods (Test)
		
		function test_minimal(testCase)
			myExport(testCase.folder, 'tempFileName')
			testCase.assertTrue( exist(fullfile(testCase.folder,'tempFileName.png'),'file')==2 )
		end
		
		function test_prefix(testCase)
			myExport(testCase.folder, 'tempFileName',...
				'prefix', 'myprefix')
			testCase.assertTrue( exist(fullfile(testCase.folder,'myprefix-tempFileName.png'),'file')==2 )
		end

		function test_suffix(testCase)
			myExport(testCase.folder, 'tempFileName',...
				'suffix', 'mysuffix')
			testCase.assertTrue( exist(fullfile(testCase.folder,'tempFileName-mysuffix.png'),'file')==2 )
		end
		
		function test_prefix_suffix(testCase)
			myExport(testCase.folder, 'tempFileName',...
				'prefix', 'myprefix',...
				'suffix', 'mysuffix')
			testCase.assertTrue( exist(fullfile(testCase.folder,'myprefix-tempFileName-mysuffix.png'),'file')==2 )
		end
		
		function test_one_format(testCase, format)
			myExport(testCase.folder, 'tempFileName',...
				'prefix', 'myprefix',...
				'suffix', 'mysuffix',...
				'formats', {format})
			testCase.assertTrue( exist(fullfile(testCase.folder,'myprefix-tempFileName-mysuffix.png'),'file')==2 )
		end
        
        function test_2_formats(testCase, format)
            myExport(testCase.folder, 'tempFileName',...
                'prefix', 'myprefix',...
                'suffix', 'mysuffix',...
                'formats', {'png','fig'})
            testCase.assertTrue( exist(fullfile(testCase.folder,'myprefix-tempFileName-mysuffix.png'),'file')==2 )
            testCase.assertTrue( exist(fullfile(testCase.folder,'myprefix-tempFileName-mysuffix.fig'),'file')==2 )
        end

	end
	
end
