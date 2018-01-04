# How to: install

Before analysing your own data, you must follow the steps here to make sure that everything is installed and working properly. Installation is pretty simple. The main steps are:

1. Install [JAGS (Just Another Gibbs Sampler)](http://mcmc-jags.sourceforge.net).
2. Install [git](https://git-scm.com) if you do not already have it installed.
3. Download the `delay-discounting-analysis` Matlab toolbox code.

You should now be set up and be able to run the demo. Set the Matlab path to the `demo` subfolder of wherever you installed `delay-discounting-analysis`, and run `run_me()` in the command window.

# Detailed install instructions

Just in case you run into problems, here are some more detailed install instructions.

## JAGS
You will need to install [JAGS (Just Another Gibbs Sampler)](http://mcmc-jags.sourceforge.net) which conducts the MCMC sampling. JAGS was written by [Martyn Plummer](http://martynplummer.wordpress.com). If you are installing on a Mac, then you may need to temporarily change your security preferences. Go to `System Preferences > Security & Privacy`. Then make sure the lock symbol is unlocked and change the setting to `Allow apps downloaded from: anywhere`. Once you have installed JAGS then you can return this setting to what you want.

**Possible PC-based error:** If you get an error along the lines of `jags not being a recognised command` then it might be worth following the advice below (provided by Sathya Narayana Sharma) before taking this up with the [JAGS forum](https://sourceforge.net/projects/mcmc-jags/)

> Go to Control Panel> System and Security> System. Select Advanced System Settings from the left panel. On the 'Advanced' tab, click Environment Variables. Under System Variables, select 'Path' and click Edit. Add the path to JAGS in the Variable Value (eg. C:\Program Files\JAGS\JAGS-4.2.0\x64\bin). Do this after putting a semicolon to separate this path from the last path existing in that section.

## git
In order for this `delay-discounting-analysis` toolbox to install other github repositories it relies upon, then we need to have [git](https://git-scm.com) installed. Please follow the instructions on this site, but it is doable both by command line instructions or nice auto installer just like any other app.

## This `delay-discounting-analysis` toolbox

**Programmatically:** You can also install programmatically. I recommend doing this as it is then easier to update to new versions with one simple command. First navigate to the folder where you wish to install the toolbox, and in Matlab, type:

```matlab
system('git clone --depth=1 https://github.com/drbenvincent/delay-discounting-analysis.git')
```

And if you want to update as new commits are made (and version released), you can type this, again into Matlab

```matlab
system('git pull')
```

**Old school, manual way:** You can just download a `.zip` file from the [latest release page](https://github.com/drbenvincent/delay-discounting-analysis/releases) of the repository. Unzip and place the `ddToolbox` folder in some place that you like, perhaps where you keep other Matlab toolboxes.
