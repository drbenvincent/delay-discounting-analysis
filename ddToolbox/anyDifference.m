function anyDifference

% Is there a difference between the posterior estimates of k in these two
% datasets?
clf

fname{1} = fullfile('output','bvGrid-BV-MCMCsamples.mat');
fname{2} = fullfile('output','kirby27-BV-MCMCsamples.mat');

for n=1:2
	load(fname{n})
	
% 	k(:,n) = export.k;
% 	kprior(:,n) = export.kprior;
	
	% DO IT IN LOG(K)
	k(:,n) = log(export.k);
	kprior(:,n) = log(export.kprior);
end

% Calculate the delta: k
diff=k(:,1) - k(:,2);
diffprior=kprior(:,1) - kprior(:,2);
%xi=linspace(min(diff(:)), max(diff(:)), 1000);



%% BAYES FACTOR
plotMCMCdist(diff,...
	struct('priorSamples',diffprior,...
	'plotStyle','lineFilled',...
	'bayesFactorXvalue',0,...
	'nbins',10001));

xlim([-2 2])

xlabel('$\log(k)$ from protocol 1 $-$ $\log(k)$ from protocol 2',...
	'Interpreter', 'latex')
forceNonExponentialTick

% Export
cd('figs')
%latex_fig(16, 7,4)
figName = 'bayesFactor';
export_fig(figName,'-png','-m3')
hgsave(figName)
cd('..')
