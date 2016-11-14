

%% Psychometric function
psycho = PsychometricFunction();
psycho.addSamples('alpha', normrnd(10, 0.5, [100 1]) )
psycho.addSamples('epsilon', normrnd(0.05, 0.01, [100 1]) )
%psycho.plotParameters()
psycho.plot()



%% Magnitude Effect function
me = MagnitudeEffectFunction()
me.addSamples('m', normrnd(-0.7, 0.1, [100 1]) )
me.addSamples('c', normrnd(0.01, 5, [100 1]) )

me.plotParameters()
clf
me.plot()


%[k, logk] = me.eval(logspace(0,3,100))


%% Hyperbolic
hyper = DF_Hyperbolic1();
logksamples = normrnd(log(1/50), 0.5, [100 1]);
hyper.addSamples('logk', logksamples )

hyper.plotParameters()
hyper.plot()




%% Exponential
e = DF_Exponential1();
ksamples = normrnd(0.001, 0.0001, [100 1]);
e.addSamples('k', ksamples )

e.plotParameters()
e.plot()




%% Hyperbolic + Magnitude Effect
% Should display a discount surface

hyperME = DF_HyperbolicMagnitudeEffect();
hyperME.addSamples('m', normrnd(-0.5, 0.1, [100 1]))
hyperME.addSamples('c', normrnd(0, 3, [100 1]) )

hyperME.plotParameters()
hyperME.plot()


