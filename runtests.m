% Run the dToolbox tests
import matlab.unittest.TestSuite;


%% Required setup

% assumes this is being run on Ben's computer
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp()


%% Run test suites
ddToolboxTestSuite = run(TestSuite.fromFolder('tests/util_tests'));
IntegrationTestSuite = run(TestSuite.fromFolder('tests/integration_tests'));

%% Display summary outputs of tests
ddToolboxTestSuite.table
IntegrationTestSuite.table

ddToolboxTestSuite
IntegrationTestSuite