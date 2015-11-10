# Hierarchical Bayesian estimation and hypothesis testing for delay discounting tasks


This repository contains the code for the paper:

**Vincent, B., T. (in press) [Hierarchical Bayesian estimation and hypothesis testing for delay discounting tasks](http://link.springer.com/article/10.3758%2Fs13428-015-0672-2), Behavior Research Methods.**

Please use the GitHub Issues feature to ask question, report a bug, or request a feature. You'll need a GitHub account to do this, which isn't very hard to set up. But you could always email me instead.

# [Documentation](https://github.com/drbenvincent/delay-discounting-analysis/wiki) and help.
Go to the [wiki](https://github.com/drbenvincent/delay-discounting-analysis/wiki) for full instructions.

# What does this do?

This code conducts Bayesian estimation and hypothesis testing on data obtained from delay discounting (aka inter-temporal choice) experiments. 

![The role of this data analysis toolbox](ddToolbox/pics/overview.png)

# Key features:

* Rather than estimating single values of delay discounting parameters (point estimates), we calculate a posterior distribution of belief over the parameters given the data.
* Hierarchical Bayesian estimation simultaneously estimates trial-level responses, and participant- and group-level parameters. 
* The widely used and easily interpreted 1-parameter hyperbolic discount function is used to not only estimate a participant’s discount rate, but how that varies as a function of reward magnitude (the magnitude effect).
* The psychometric function incorporates measurement errors, that is, participant response errors.






