function logKSamples = getLogDiscountRate(modelObject, reward, varargin)

% TODO FINISH THIS FUNCTION !!!

% TODO: ADD UNIT TESTS

plotFlag = 1;

nExperimentFiles = modelObject.data.getNExperimentFiles();

for p = 1:nExperimentFiles
	
    % TODO: VIOLATES LAW OF DEMETER?
	% get samples of (m, c)
	params(:,1) = modelObject.coda.getSamplesFromExperimentAsMatrix(p, {'m'});
	params(:,2) = modelObject.coda.getSamplesFromExperimentAsMatrix(p, {'c'});
	
	% calculate logk = m * log(reward) + c
	[posteriorMean(p), lh(p)] =...
		calculateLogK_ConditionOnReward(reward, params, plotFlag);
	
end

logKSamples = []; % TODO: RETURN SAMPLES!!!!!!

if plotFlag
    figure(1)
    lh = plot(xi,f);
    hold on
    
	removeYaxis
	title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
	xlabel('$\log(k)$','Interpreter','latex')
	axis square
end
end


function [posteriorMean,lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag)
assert(isscalar(reward),'reward should be a scalar')
lh=[];

kSamples	= magnitudeEffect(reward, params);
logKsamples = log(kSamples);

[xi] = makeXIvalues(logKsamples);

[f,xi] = ksdensity(logKsamples, xi, 'function', 'pdf');

posteriorMode = xi( argmax(f) );
posteriorMean = mean(logKsamples);

end

function [xi] = makeXIvalues(samples)
% create a set of x values based on the range of samples, but add some padding
[~,X] = hist(samples);
range = X(end)-X(1);
Xpadded(1) = X(1) - range/2;
Xpadded(2) = X(end) + range/2;
xi = linspace(Xpadded(1), Xpadded(2), 1000);
end
