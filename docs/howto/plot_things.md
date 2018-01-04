Once you have your 'fitted' model object, obtained with code such as:

```
myDataObject = Data(datapath, 'files', allFilesInFolder(datapath, 'txt'));
myModel = ModelHierarchicalExp1(myDataObject)
```

then you use this to create a variety of plots.

## Plot all the things

If you call

```
   myModel.plot()
```

then an annoyingly large number of plots will be generated. This is perhaps the best way to batch generate figures to visually inspect the data and inferences.

## Generating specific plots

You can also get much more specific things plotted.

_What plots are available?_ There are a number of plot methods available to you, that you can call on the model object. These can be discovered by typing: `methods(myModel)` <kbd>Enter</kbd>, or `myModel` <kbd>Enter</kbd> into the command line.

Examples include:

- `myModel.plotDiscountFunction(1)` which will plot the data + inferred discount function for experiment file 1
- `myModel.plotDiscountFunctionGrid()` will plot all the discount functions in many sub panels.
- `myModel.plotPosteriorDiscountFunctionParams(1)` will plot the posterior distribution of discounting related parameters for that model, for experiment file 1.
- `myModel.plotExperimentOverviewFigure(1)` will generate a multi panel plot summarising lots of interesting things relating to experiment file 1.

The best way to find out how to call each of the plot methods (i.e. what arguments they take, if any) is to type `help myModel.<plot method name>`, for example, `help myModel.plotDiscountFunction`
