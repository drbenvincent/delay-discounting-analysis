classdef test_myExport < matlab.unittest.TestCase

	properties
		figHandle
		folder
	end
	
	properties (TestParameter)
		format = {'png', 'pdf', 'png', 'eps', 'ps', 'svg', 'fig'}
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
		
		function test_one_format(testCase)
			format = 'png';
			myExport(testCase.folder, 'tempFileName',...
				'prefix', 'myprefix',...
				'suffix', 'mysuffix',...
				'formats', {format})
			testCase.assertTrue( exist(fullfile(testCase.folder,['myprefix-tempFileName-mysuffix.' format]),'file')==2 )
		end
        
        function test_2_formats(testCase)
			format_list = {'png', 'pdf'};
            myExport(testCase.folder, 'tempFileName',...
                'prefix', 'myprefix',...
                'suffix', 'mysuffix',...
                'formats', format_list)
            testCase.assertTrue( exist(fullfile(testCase.folder, ['myprefix-tempFileName-mysuffix.' format_list{1}]),'file')==2 )
			testCase.assertTrue( exist(fullfile(testCase.folder, ['myprefix-tempFileName-mysuffix.' format_list{2}]),'file')==2 )
		end
		
		function test_error(testCase)
			format = 'throw_error_please';
			myExport(testCase.folder, 'tempFileName',...
				'prefix', 'myprefix',...
				'suffix', 'mysuffix',...
				'formats', {format})
			% no explicit test here yet, just catches error if it exists
		end

	end
	
end
