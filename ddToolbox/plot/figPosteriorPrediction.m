function figPosteriorPrediction(data)
    % MAIN FUNCTION TO PRODUCE MUTLI-PANEL FIGURE

    figure(1), colormap(gray), clf

    subplot(2,2,1)
    pp_plotTrials()
    %if p<obj.data.nParticipants, set(gca,'XTick',[]), end

    subplot(2,2,2)
    pp_plotGOFdistribution()

    subplot(2,2,3)
    pp_plotPredictionAndResponse()

    subplot(2,2,4)
    pp_ploptPercentPredictedDistribution()

    function pp_plotGOFdistribution()
        uni = mcmc.UnivariateDistribution(data.GOF_distribtion(:),...
            'xLabel', 'goodness of fit score',...
            'plotStyle','hist',...
            'pointEstimateType',data.pointEstimateType);
    end

    function pp_ploptPercentPredictedDistribution()
        uni = mcmc.UnivariateDistribution(data.percentPredictedDistribution,...
            'xLabel', '$\%$ proportion responses accounted for',...
            'plotStyle','hist',...
            'pointEstimateType',data.pointEstimateType);

        axis tight
        vline(0.5)
        set(gca,'XLim',[0 1])
	end

    function pp_plotTrials()
        % plot predicted probability of choosing delayed
        bar(data.participantPredictedResponses,'BarWidth',1)

        box off
        axis tight
        % plot response data
        hold on
        plot([1:data.trialsForThisParticant], data.R, '+')
        title(data.titleString)

        xlabel('trial')
        ylabel('response')
        legend('prediction','response', 'Location','East')
    end

    function pp_plotPredictionAndResponse()
        h(1) = plot(data.participantPredictedResponses, data.R, '+');
        xlabel('P(choose delayed)')
        ylabel('Response')
        legend(h, 'data')
        box off
    end

end
