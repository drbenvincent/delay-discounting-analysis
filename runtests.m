

% Run the dToolbox tests
import matlab.unittest.TestSuite;


%% Required setup
disp('=== DOING NECESSARY TOOLBOX SETUP BEFORE RUNNING TESTS ===')
% assumes this is being run on Ben's computer
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp()


%% RUN ALL TESTS
testSuite = TestSuite.fromFolder('tests');
testSuite = testSuite.run()
testSuite.table



% %% just run unit tests
% % Learn more about using TAGS here:
% % http://uk.mathworks.com/help/matlab/matlab_prog/tag-unit-tests.html
% 
% unitTestSuite = TestSuite.fromFolder('tests', 'Tag','Unit');
% unitTestSuite = unitTestSuite.run()
% unitTestSuite.table



