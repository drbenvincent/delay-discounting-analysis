function [estimated_mode, XI, p, ci95] = calcUnivariateSummaryStats(samples, supp)

samples = samples(:);

%method = 'ksdensity';	% matlab built in. Slow
method = 'kde';			% faster
N = 10000;

switch method
	
	case{'ksdensity'}
		
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
				case{2}
			end
		else
			switch supp
				case{'positive'}
					supp=[0 max(samples)*1.5];
			end
		end
		[~,F,XI,~]=kde(samples,N,supp(1),supp(2));
end

estimated_mode = XI( argmax(F) );
p = F./sum(F); % normalise
ci95 = prctile(samples,[5 95]);

fprintf('mode=%2.3f (%2.3f - %2.3f)\n', estimated_mode, ci95(1), ci95(2))

return