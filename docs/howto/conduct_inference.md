# How to: conduct inference

Before trying to analyse your own data, you should check everything is working ok by running the demo analysis, see the [Run the demo](http://drbenvincent.github.io/delay-discounting-analysis/tutorial/run_demo_code) page.

The easiest way to analyse your own data is to use the example provided in the `demo` folder and modify for your own purposes. Below is an overview of how to organise a project to analyse your own data.

* Create a project folder for example `myProjectFolder`.
Ensure that it has the following subdirectories:
* `data`. See the [Store raw data](http://drbenvincent.github.io/delay-discounting-analysis/howto/store_raw_data.html) how to.
* `output`. Various outputs and figures will be stored in this folder.

The `myProjectFolder/output` and `myProjectFolder/figs` start empty and results from the analysis are saved in these folders.

# Import other information about your experiment
While this toolbox focusses upon the analysis of discounting tests, these often exist within the context of a larger experiment. For example, each discounting file you have may correspond to a participant, within a particular condition, and you may have various other measures such as age, sex, or any number of other experimental measures. It is possible to import a spreadsheet of data for your experiment, which will make your analysis workflow much easier. If you opt to do this, the toolbox will export a new spreadsheet (`.csv` file) with the various discounting and posterior predictive information added. This file can then be imported directly into a stats package such as [JASP](https://jasp-stats.org).

How to do this? When you create your `Data` object, you can pass in either a Matlab `Table` which you've created yourself, or you can pass in a path + filename to a `.csv` spreadsheet of experiment variables. See [#181](https://github.com/drbenvincent/delay-discounting-analysis/issues/181) for more information. I hope to add more information and a worked example on the wiki soon. Do feel free to get in touch if more guidance is needed here.

# Create an analysis 'script'

Copy `run_me.m` from the `demo` folder into `myProjectFolder`. This will be your main Matlab script to run the your analysis. Make sure you read the comments and instructions in the file, for example you will need to update the paths to data etc.

## Define which data files to use
The first input argument when you call a model function has to be a `Data` object. In the example I provide, I do this quite concisely with the code `Data(datapath, 'files', allFilesInFolder(datapath, 'txt'))`. The function `allFilesInFolder()` is just a utility function which returns a cell array of filenames. You can change this to whatever you like to make data selection easy. One example would simply be to manually pass in a cell array of filenames such as

should be a cell array of filenames. You can choose to set this up by defining a cell array manually, such as

```matlab
fnames = {'AC-kirby27-DAYS.txt',...
          'CS-kirby27-DAYS.txt',... % more filenames here
          'NA-kirby27-DAYS.txt'};
```
and then just use `Data(datapath, 'files', fnames)`.

# Run the analysis
You should now be able to run the analysis by entering `[model] = run_me()` into the Matlab command window.
