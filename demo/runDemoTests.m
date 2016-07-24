% Run this function to run all tests in the folder
% These are intended to be 'integration tests'

import matlab.unittest.TestSuite;
testResults = run(TestSuite.fromFolder('tests'));
