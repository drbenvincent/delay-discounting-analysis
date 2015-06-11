function  uni = univariateAnalysisALL(samples)


fields = fieldnames(samples);


display('Analysing univariate summary stats:')

for n=1:numel(fields)
	
	display(fields{n})
	
	%tempSamples = getfield(samples, fields{n});
	tempSamples = samples.(fields{n}); % using dynamic fieldname notation
	
	[chains, nSamples, M] = size(tempSamples);
	
	for m = 1:M 
		
		temptempsamples = vec(tempSamples(:,:,m));
		
		[estimated_mode, ~, ~, ~] = sampleStats( temptempsamples , []);
		
		% I want to use the 95% HDI using this function
		[ci95] = HDIofSamples(temptempsamples, 0.95);
		
		uni.(fields{n}).CI95(:,m) = ci95;
		uni.(fields{n}).mode(m) = estimated_mode;
	end
	
	
end