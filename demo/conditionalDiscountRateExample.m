% You may be interested in the discount rate (at the group and participant
% levels) at a particular reward magnitude. The method
% conditionalDiscountRatePlots() plots participant and group level
% conditional posterior (predictive) distributions. That is...
% The posterior distribution of discount rate (log(k)) for a given reward
% magnitude.
%
% Below we calculate and plot the discount rates for reward magnitudes of
% £100 and £1,000
function conditionalDiscountRateExample(model)

assert(strcmp(model.discountFuncType,'me'),...
	'only meaningful to run when magnitude effect has been modelled')

figure(1), clf
plotFlag = true;
ax(1) = subplot(1,2,1);
model.conditionalDiscountRates(100, plotFlag);
ax(2) = subplot(1,2,2);
model.conditionalDiscountRates(1000, plotFlag);
linkaxes(ax,'xy')
end