function figPosteriorPrediction(nQuestions, percentPredictedDistribution, participantPredictedResponses, R, titleString, pointEstimateType, GOF_distribtion)
    % MAIN FUNCTION TO PRODUCE MUTLI-PANEL FIGURE

    figure(1), colormap(gray), clf

    subplot(2,2,1)
    pp_plotTrials(nQuestions, participantPredictedResponses, R, titleString)
    %if p<obj.data.nParticipants, set(gca,'XTick',[]), end

    subplot(2,2,2)
    pp_plotGOFdistribution(GOF_distribtion, pointEstimateType)

    subplot(2,2,3)
    pp_plotPredictionAndResponse(participantPredictedResponses, R)

    subplot(2,2,4)

    pp_ploptPercentPredictedDistribution(percentPredictedDistribution, pointEstimateType)

end


function pp_plotGOFdistribution(gofscores, pointEstimateType)
    uni = mcmc.UnivariateDistribution(gofscores(:),...
        'xLabel', 'goodness of fit score',...
        'plotStyle','hist',...
        'pointEstimateType',pointEstimateType);
end


function pp_ploptPercentPredictedDistribution(percentPredictedDistribution, pointEstimateType)
    uni = mcmc.UnivariateDistribution(percentPredictedDistribution,...
        'xLabel', '$\%$ proportion responses accounted for',...
        'plotStyle','hist',...
        'pointEstimateType',pointEstimateType);

    axis tight
    vline(0.5)
    set(gca,'XLim',[0 1])
end


function pp_plotTrials(nQuestions, participantPredictedResponses, R, titleString)
    % plot predicted probability of choosing delayed
    bar(participantPredictedResponses,'BarWidth',1)

    box off
    axis tight
    % plot response data
    hold on
    plot([1:nQuestions], R, '+')
    title(titleString)

    xlabel('trial')
    ylabel('response')
    legend('prediction','response', 'Location','East')
end


function pp_plotPredictionAndResponse(participantPredictedResponses, R)
    h(1) = plot(participantPredictedResponses, R, '+');
    xlabel('P(choose delayed)')
    ylabel('Response')
    legend(h, 'data')
    box off
end
