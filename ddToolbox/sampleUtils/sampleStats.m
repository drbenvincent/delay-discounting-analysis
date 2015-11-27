function [estimated_mode, XI, p, ci95] = sampleStats(samples, supp)

% ensure this is a vector
samples = samples(:);

N = 10000;

%method = 'ksdensity';	% matlab built in. Slow
method = 'kde';			% faster

switch method
	
	case{'ksdensity'}
		% Matlab built in ksdensity is rather slow
		
		if numel(supp)==0
			% Compute the kernel density estimate based on MCMC samples
			[F,XI]=ksdensity(samples, 'npoints',N);
		else
			% Compute the kernel density estimate based on MCMC samples
			[F,XI]=ksdensity(samples, 'support', supp, 'npoints',N);
		end
		
	case{'kde'}
		
		if isnumeric(supp)
			switch numel(supp)
				case{0}
					supp = [min(samples),max(samples)];
					%[~,F,XI,~]=kde(samples,N,min(samples),max(samples)*1.5);
				case{2}
					%[~,F,XI,~]=kde(samples,N,supp(1),supp(2));
			end
		else
			switch supp
				case{'positive'}
					supp=[0 max(samples)*1.5];
			end
		end
		
		[~,F,XI,~]=kde(samples,N,supp(1),supp(2));
		
		% 		if numel(supp)==0
		% 			% no support specified
		% 			% Compute the kernel density estimate based on MCMC samples
		% 			[~,F,XI,~]=kde(samples,N,min(samples)*1.5,max(samples)*1.5);
		% 		else
		% 			switch supp
		% 				case{'positive'}
		% 					supp=[0 max(samples)*1.5];
		% 			end
		% 			% Compute the kernel density estimate based on MCMC samples
		% 			[~,F,XI,~]=kde(samples,N,supp(1),supp(2));
		% 		end
end

% now calculate the mode
[~,index]=max(F);
estimated_mode = XI(index);

% normalise
p=F./sum(F);

ci95 = prctile(samples,[5 95]);

fprintf('mode=%2.3f (%2.3f - %2.3f)\n',...
	estimated_mode, ci95(1), ci95(2))

return