# The psychometric link function we use

The toolbox currently uses a psychometric link function that converts present subjective values of each offer, to a response probability.

This psychometric function

    P(choose delayed) = epsilon + (1-2*epsilon) * Phi((VB-VA)/alpha)

maps present subjective values of each option (`VA` and `VB`) to a response probability. This involves 2 parameters (`alpha` and `epsilon`) which are related to response errors. Note that `Phi()` is the standard cumulative normal function.

## Issues with this link function
Because we have 2 parameters relating to response errors, this can sometimes cause problems with our inferences. For an individual experiment with around 10-20 responses it is easy to imagine that the data are not sufficient to fully determine the values of `alpha` and `epsilon`.

However, this is a clear situation where hierarchical inference can help. Using the mixed or hierarchical model subtypes, we can use the shrinkage effect of the hyper priors over `alpha` and `epsilon` to help. Put another way: while on an individual level we might not be able to well-identify `alpha` and `epsilon`, we can use prior knowledge at the group level to help our inferences at the experiment level.

## Priors over error rate (`epsilon`) and comparison acuity (`alpha`)
The priors and hyper priors for `alpha` and `epsilon` used in the paper worked well for the dataset examined. Since then it has become clear that for other datasets, sometimes we need to use more aggressive priors that assert beliefs that `alpha` and `epsilon` take on small values. This is because, if these parameters are high, then the model cannot predict responses with a strong probability (near 0 or 1), which makes a much wider range of discounting parameter values plausible with the data.

See the [changing the priors](https://github.com/drbenvincent/delay-discounting-analysis/wiki/Changing-the-priors) how-to page to get started with this. Note that for some discount functions I have already set priors for `alpha` and `epsilon` to assert stronger prior belief that the parameters take on low values.

# Alternative link functions
Other common link functions might include the `softmax` or `logistic` link functions. The psychometric function we use can be seen as simply swapping out a `logistic` link function (which would have an equivalent `alpha` parameter) and then adding the term `epsilon + (1-2*epsilon)` which deals with baseline error rates.

At the moment the toolbox only allows use of the psychometric link function, but there is an open issue ([#195](https://github.com/drbenvincent/delay-discounting-analysis/issues/195)) for this.
