function logKSamples = getLogDiscountRate(varargin)

% TODO FINISH THIS FUNCTION !!!

% TODO: ADD UNIT TESTS

% Extract and plot P( log(k) | reward)
warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
conditionalDiscountRates_ParticipantLevel(reward, plotFlag)

if plotFlag
	removeYaxis
	title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
	xlabel('$\log(k)$','Interpreter','latex')
	axis square
end
end




function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
nParticipants = obj.data.nParticipants;
for p = 1:nParticipants
	params(:,1) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'m'});
	params(:,2) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'c'});
	% ==============================================
	[posteriorMean(p), lh(p)] =...
		calculateLogK_ConditionOnReward(reward, params, plotFlag);
	% ==============================================
end
warning('GET THESE NUMBERS PRINTED TO SCREEN')
% 			logkCondition = array2table([posteriorMode'],...
% 				'VariableNames',{'logK_posteriorMode'},...)
% 				'RowNames', num2cell([1:nParticipants]) )
end