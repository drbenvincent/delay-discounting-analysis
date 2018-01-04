**The toolbox primarily uses JAGS. Inference using STAN is currently highly experimental. Not all discount functions are written in STAN model code, and not much work has gone in to checking things are working fine.**

## STAN installation and setup steps

In order to use [STAN](http://mc-stan.org) to conduct inference, it is necessary to do a bit of installation.
- [MatlabStan](https://github.com/brian-lau/MatlabStan) - this is automatically installed by the toolbox.
- [MatlabProcessManager](https://github.com/brian-lau/MatlabProcessManager/) - this is automatically installed by the toolbox.
- [CmdStan](http://mc-stan.org/interfaces/cmdstan.html) - you will need to download AND build this. Don't forget the second step. It's detailed in the manual, but I missed it the first time.

**You will also need to locate the file `stan_home.m` (in the `matlabStan` package) and set the path in that file to the location that you placed CmdStan.**

## Status

I am _not_ actively working on supporting inference with STAN. I'd be very happy if someone wanted to progress the toolbox support for STAN however. Please see the [CONTRIBUTING.md](https://github.com/drbenvincent/delay-discounting-analysis/blob/master/CONTRIBUTING.md) document.
