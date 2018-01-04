**NOTE: It is highly recommended that thought goes into the priors. They need to be appropriate for your experimental context.**

I opted to fully define priors within the `*.jags` model files. While it would have been possible to inject different prior and precision parameters for easy user-updates of the priors, I've currently avoided this. This is because it allows freedom to change the form of the priors (e.g. what distributions we use). It may well be that this is not so convenient, so this might be some work for the future. Feel free to request the change, or to contribute the changes yourself via a pull request.

The jags model files can be found in the relevant subdirectories of `ddToolbox/models/`.

## Example
The file `separateLogK.jags` implements the Hyperbolic discount function, with no hierarchical inferences. We can see the priors for each experiment are defined as normally distributed

```
for (p in 1:nRealExperimentFiles){
    logk[p] ~ dnorm(logk_MEAN, logk_PRECISION)
}
```

where

```
logk_MEAN      <- log(1/50)
logk_PRECISION <- 1/(2.5^2)
```

The prior mean of `log(1/50)` equates to a belief that the average half life will be 50 days (because half life equals `1/k` for hyperbolic discounting). If we are working with a specific subject population where we have prior beliefs about their mean discount rate, then we could change this prior mean accordingly.

We can also update the precision of the prior distribution (precision equals inverse variance). If we have very little prior knowledge about the `logk` values of our participant population then we can create an even broader prior by increasing the variance from `2.5^2` upwards.
