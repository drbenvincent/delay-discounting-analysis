function  uni = univariateAnalysis(samples, fields, support)

% fields={'lr', 'sigma', 'm', 'c', 'groupMmu', 'groupCmu'};
% support={'positive', 'positive', [], [], [], []};

display('Analysing univariate summary stats:')

for n=1:numel(fields)
	display(fields{n})
	samplesForThisField = getfield(samples, fields{n});
	[chains, nSamples, M] = size(samplesForThisField);
	for m = 1:M
		temptempsamples = vec(samplesForThisField(:,:,m));
		
		[estimated_mode, ~, ~, ~] = sampleStats( temptempsamples , support{n});
		
		% I want to use the 95% HDI using this function
		[ci95] = HDIofSamples(temptempsamples, 0.95);
		
		uni.(fields{n}).CI95(:,m) = ci95;
		uni.(fields{n}).mode(m) = estimated_mode;
	end
end
return