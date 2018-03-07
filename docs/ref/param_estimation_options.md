# Parameter estimation options

When initiating model parameter estimation, there is only one required input, which is the a data. So you can get up and running very quickly with a simple call like this...

```matlab
myData = Data(datapath, 'files', allFilesInFolder(datapath, 'txt'));
model = ModelHierarchicalME(myData);
````

## The model being used
The function being called constructs a `Model` object and then proceeds to do parameter estimation. The toolbox provides a number of models to use, and it is important to pick the one appropriate for your data and research question. See the [Models](https://github.com/drbenvincent/delay-discounting-analysis/wiki/Models) page for more information.

## Required function argument: a `Data` object
The first input has to be a `Data` object. This can be constructed as follows

```matlab
Data(datapath, 'files', allFilesInFolder(datapath, 'txt'))
````
The first argument must be a string, specifying the location of data files. We also need one key/value pair:

| Key  | Values |
| --- | --- |
| `'files'` | must be a cell array of strings |

the input can either be a manually specified cell array of strings, or the output of a utility function that yields a cell array of strings. Here, I use a helper function `allFilesInFolder()` which outputs a cell array of strings, namely all of the `.txt` files in the specified `datapath`. You can feel free to write your own utility function, as long as the input is a cell array of strings, it should work.

## Optional key/value pairs

The rest of the arguments are optional key/value pairs

| Key  | Values |
| --- | --- |
| `'timeUnits'` | `'minutes'` or `'hours'` or `'days'` [default] |
| `'pointEstimateType'` | `'mean'` or `'median'` or `'mode'` [default] |
| `'shouldPlot'` | `'yes'` or `'no'` [default]|
| `'shouldExportPlots'` | `'true'` [default] or `'false'` |
| `'exportFormats'` | a cell array of output formats, e.g. `{'png', 'pdf'}` (default is `{'png'}` only) |
| `'shouldExportPlots'` | `true` or `false` |
| `'savePath'` | a string defining the folder location to save exports in |
| `'mcmcParams'` | a structure (see below) |

You can override the default MCMC sampling parameters by providing a structure in the form of:
```matlab
struct('nsamples', 10^5,...
    'nchains', 4,...
    'nburnin', 10^3)
```

## Example
Please see `run_me.m` for a working example. But here is a quick example of how to conduct the parameter estimation
```matlab
model = ModelHierarchicalME(Data(datapath, 'files', allFilesInFolder(datapath, 'txt')),...
    'timeUnits', 'days',...
    'savePath', fullfile(pwd,'output','my_analysis'),...
    'pointEstimateType', 'mode',...
    'shouldPlot', 'no',...
    'shouldExportPlots', false,...
    'exportFormats', {'png'},...
    'mcmcParams', struct('nsamples', 100000, 'nchains', 4, 'nburnin', 1000));
```
