function plotDiscountFunctionGRW(personInfo, intervals)
% Create a plot to visualise a discount function, from the Gaussian Random
% Walk model. Includes posterior predictive distribution of indifference
% points and the behavioural data.

%% visualise the posterior predictive indifference points
ribbon_plot(personInfo.delays, personInfo.dfSamples, intervals)

hold on

%% overlay behavioural data
plotDiscountingData(personInfo.data)

%% formatting
title(personInfo.participantName)
xlabel('delay')
%axis square
axis tight
hline(1)
set(gca,'YLim',[0 2.5])

%% add AUC measure text to graph
auc_str = sprintf('mean AUC: %1.2f', mean(personInfo.AUCsamples));
addTextToFigure('TR',auc_str, 15, 'latex')

drawnow

end
