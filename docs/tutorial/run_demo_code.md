# Running the demo code

Your first steps should be to ensure the toolbox is installed and working properly. So I recommend first making sure you can run through these steps. If there are problems, they are most likely to be fixed by checking you have installed all the dependencies.

1. If you have not already, install the toolbox code onto your local machine. See the [install the toolbox](https://github.com/drbenvincent/delay-discounting-analysis/wiki/Install-the-toolbox) how-to.
2. Load Matlab, and set the current directory to `delay-discounting-analysis/demo`. This is your home project folder.
3. Run the demo by typing `run_me()` in the command window.

Note that the demo code is set to run with a relatively low number of MCMC samples. Setting this number higher (100000 or higher) is recommended for more trustworthy results.

**Known bug:** Sometimes a series of warnings will be displayed (relating to git and the attempted install of other repositories required by this one). We have found that simply running the `run_me()` command again will work.
