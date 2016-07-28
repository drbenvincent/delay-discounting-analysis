%RUNALLTESTS
% A script to run the tests
%
% Manually run specific tests like this...
% result = runtests('tests/test_calculateAUC.m')


import matlab.unittest.TestSuite;


%% Required setup
disp('=== DOING NECESSARY TOOLBOX SETUP BEFORE RUNNING TESTS ===')
% assumes this is being run on Ben's computer
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp()

initial_dir = cd;
cd('~/git-local/delay-discounting-analysis/')


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



