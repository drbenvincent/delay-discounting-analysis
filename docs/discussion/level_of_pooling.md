The published paper presented the [ModelHierarchicalME](https://github.com/drbenvincent/delay-discounting-analysis/wiki/Regular-hierarchical-model) model, which estimates the magnitude effect, and uses hierarchical Bayesian inference (on all parameters) to make estimates about group-level discounting behaviour.

Placing a hyper-prior on a parameter will:

1. allow you to make inferences about group-level effects. This is useful if you want to compare two conditions etc.
2. cause shrinkage, which is a desirable thing for multi-level modelling (see below).

_You will need to decide, based upon your research question and experiment design, whether you want to use hyper-priors (ie have group shrinkage) on all, some or none of the model's parameters._

## Should you use fully hierarchical models?
If your dataset consists of one homogenous group, then you can use these 'hierarchical' models that have hyperpriors on all parameters.

However, there are times when it will _not_ be appropriate to place a hyper-prior on a parameter. If you dataset is heterogeneous (i.e. if you have multiple experimental conditions or distinctly different participant groups) then you should either:
- split your data up and apply the hierarchical models to each homogenous group, or
- use models which don't place hyperpriors on the discounting parameters (I've called these 'mixed' models), or
- use models with no hyperpriors on any parameters (I've called these 'separate' models).

## Mixed (semi-hierarchical) models
One situation were you would _not_ want to use hierarchical inference is when you have a heterogeneous data sample. For example, if you are testing different groups of people, or they are in different conditions, then it is not valid to assume all participants are coming from a single group. If anything this would lead you to miss genuine differences in discounting behaviour. The 'mixed' models:
- do use prior knowledge about the important discount rate parameters (either `logk` or `(m, c)`).
- but _do not_ use hierarchical inference on the important discounting parameters to avoid the shrinkage effect that would occur from assuming they derive from a single group.
- do use hierarchical inference on the 'nuisance' parameters describing response errors (`alpha` and `epsilon`) because these parameters are unlikely to vary systematically between participant groups or conditions. If you suspect that this might not be the case, then you should use the entirely non-hierarchical models below.

## Non-Hierarchical (separate) models
While hierarchical inference is very useful and has a number of virtues (discussed in the paper), it is also not appropriate in all research contexts. For example, it assumes that participants are drawn from one group. This assumption is not a sensible one to make if you know _a priori_ that your participants come from different populations, or control vs experiment groups etc.

In these cases the hierarchical estimation would act to decrease the chances of finding differences in discounting behaviour between groups because of the 'shrinkage effect' common in hierarchical models. In these cases, it would be ideal to use models which explicitly incorporate the group or condition that participant data comes from. These models might be developed in the future. If you develop them, that would be interesting, please get in touch.

Currently, the most appropriate way to deal with this is to do away with the hierarchical estimation and make independent inferences about each participant. See the table above for the non-hierarchical models available so far.
