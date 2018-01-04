The toolbox uses Markov Chain Monte Carlo (MCMC) methods. These methods are very powerful, but they also require diligence in checking that the inferences made are reliable.

**One should not blindly run an analysis and publish the results. It is important to do your due diligence.**

This can be a little complex, but below I outline some steps to go through.

## Identifying non-convergence

As of writing the default is to run 4 MCMC chains, and for those new to MCMC, this can be thought of as running 4 separate analyses. The point of this is so that we can see if these separate analyses agree with one another. A key part of this is whether the chains (which have different initial points in parameter space) have converged. This is important, because if they have not converged then we have no real faith that the MCMC samples obtained provide an accurate approximation to the true posterior distribution.

The Rhat statistic is calculated for all monitored variables. A convergence report is saved in a text file and printed to the Matlab command window. Any cases where `Rhat>1.01` are flagged.

We can also plot the MCMC chains for visual inspection. I won't try to detail properties of good/bad MCMC chains here as this is done very well and in high levels of detail elsewhere.

**One should really confirm chain convergence before really trusting the analyses, let alone publishing them. Below I outline a few steps that can be taken to deal with this.**

## Strategy 1 - ensure you are generating enough MCMC samples
For anything more than very simple models, it can be necessary to generate large numbers of MCMC samples to get an accurate
approximation of the posterior. In many cases, convergence issues will disappear as the number of samples increases. As a rough guide, I have found that using 10^5 total samples is the absolute minimum, even for exploratory analysis or code testing. But to run a 'proper' analysis, I would recommend generating at least 10^6 samples. This can of course take some time to compute, which is why it is good to have a multi-core machine with the Matlab Parallel Computing Toolbox installed. If not, you just have to start running these analyses overnight.

## Strategy 2 - participant exclusion
The first thing to do is to go thoroughly examine participant data and exclude problematic participants. Note that this is _not_ determined by whether participants have chain convergence issues (although it could be) but more by the data. This is discussed extensively in the previous wiki section on data vetting. After you have excluded participants according to this advice, or your own criteria, then re-run the analysis and see if convergence issues persist.

## Strategy 3 - investigate the appropriateness of the priors
The priors specified in the paper worked very well for the dataset at hand. Now I have run the analysis on more varied and challenging datasets, I have found that some of the priors could be improved a little. Please see the next wiki section on priors for more information.
 
## Strategy 4 - ask me
Feel free to get in touch. I'll see what I can do. You could either submit a GitHub issue, or email me.

## Strategy 5 - get better data
One reason for non-convergence of chains is simply that the data to hand is insufficient to constrain the parameters. So you could either run delay discounting tasks with more data, or use better/different delay discounting protocols. 
