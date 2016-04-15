% Copyright 2014 The MathWorks, Inc.
% Runs all the tests in the each.test package

if ~exist('matlab.unittest.TestCase','class')
    error('Each:EarlierVersion','This test file requires the unit testing framework.')
end

me = meta.package.fromName('each.test');
tests = { me.ClassList.Name };

for test = each(tests)
    run( feval( test ) );
end
