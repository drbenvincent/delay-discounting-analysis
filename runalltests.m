%runalltests
% A script to run the tests
%
% Manually run specific tests like this...
% result = runtests('tests/test_calculateAUC.m')

% required
import matlab.unittest.TestSuite;

% optional
import matlab.unittest.plugins.CodeCoveragePlugin 

% if we want to create a suite by suite = TestSuite.fromPackage('tests');
%import matlab.unittest.TestRunner 


%% Required setup
disp('=== DOING NECESSARY TOOLBOX SETUP BEFORE RUNNING TESTS ===')
% assumes this is being run on Ben's computer
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp()

initial_dir = cd;
cd('~/git-local/delay-discounting-analysis/')

%% Run a single test file by...
% make sure test folder is on path
% >> run(name_of_test_file); results.table
% eg. run(test_create_subplots)

%% RUN ALL TESTS
suite = TestSuite.fromFolder('tests');
suite = suite.run()
suite.table

%% Run tests - with coverage report
% % create a suite of tests
% suite = TestSuite.fromFolder('tests');
% % create a test runner
% runner = TestRunner.withTextOutput;
% % add CodeCoveragePlugin
% runner.addPlugin(CodeCoveragePlugin.forFolder(pwd, 'IncludingSubfolders', true))
% % get the runner to run the suite of tests
% result = runner.run(suite);


%% Get siri to tell me results
nPassed = sum([suite.Passed]==1);
nFailed = sum([suite.Passed]==0);
nTests = numel(suite);
if nFailed == 0
	report_str = sprintf('All %d tests passed. Winning', nTests);
else
	report_str = sprintf('%d tests passed, %d tests failed', nPassed, nFailed);
end

speak(report_str)




% %% just run unit tests
% % Learn more about using TAGS here:
% % http://uk.mathworks.com/help/matlab/matlab_prog/tag-unit-tests.html
% 
% unitTestSuite = TestSuite.fromFolder('tests', 'Tag','Unit');
% unitTestSuite = unitTestSuite.run()
% unitTestSuite.table



