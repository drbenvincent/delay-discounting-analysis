
parpool open

addpath(genpath('../'))

%% Load and prep the observed data
load('all_data.mat')

log_reward	= data(:,1);
log_k		= data(:,2);
study		= data(:,3)-7;  % so studies range from 1-19

clear data

% create vector of number of data points per study
%for n=1:max(study), N(n) = sum(study==n); end

observed.logreward = log_reward;
observed.logk = log_k;
observed.study = study;

observed.probeReward = log( logspace(1,6,6) );

%% run inference using JAGS model

nchains = 4;

% Initialize Unobserved Variables
for i=1:nchains
	init(i).sigma	= rand*10;
	init(i).mu_m	= randn;
	init(i).sigma_m	= rand*10;
	init(i).mu_c	= randn;
	init(i).sigma_c	= randn*10;
end



[samples, stats] = matjags( ...
	observed, ...
	fullfile(pwd, 'JAGS_hieriarchical_linear_regression.txt'), ...
	init, ...
	'doparallel' , 1, ...
	'nchains', nchains,...
	'nburnin', 1000,...
	'nsamples', 100000, ...
	'thin', 1, ...
	'monitorparams', {'sigma', 'mu_m', 'sigma_m', 'mu_c', 'sigma_c'...
	'groupM','groupC','probeLogK'}, ...
	'savejagsoutput' , 0 , ...
	'verbosity' , 1 , ...
	'cleanup' , 1 , ...
	'rndseed', 1,...
	'dic',0);

%% plot chains
figure, plot(samples.sigma'), title('sigma')
figure, plot(samples.mu_m'), title('mu_m')
figure, plot(samples.sigma_m'), title('sigma_m')
figure, plot(samples.mu_c'), title('mu_c')
figure, plot(samples.sigma_c'), title('sigma_c')

%% plot posterior distributions
figure, hist(samples.sigma(:), 31), title('sigma')

%%
figure(1), clf, colormap(gray)

text_size = 16;

subplot(6,2,7)
h = histogram(samples.mu_m(:), 31,'Normalization','probability'), xlabel('\mu_m '), box off;
%str=sprintf('\mu_m \sim Normal(%2.3f, %2.3f)', mean(samples.mu_m(:)), std(samples.mu_m(:)));
str={ sprintf(' Normal$$(%2.3f, %2.3f) $$',mean(samples.mu_m(:)), std(samples.mu_m(:))) };
add_text_to_figure('TL',str, text_size, 'latex')
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';

subplot(6,2,9)
h = histogram(samples.sigma_m(:), 31,'Normalization','probability'), xlabel('\sigma_m'), box off
%str=sprintf('mean = %2.3f \nvar = %2.3f', mean(samples.sigma_m(:)), std(samples.sigma_m(:)));
str={ sprintf(' Normal$$(%2.3f, %2.3f) $$',mean(samples.sigma_m(:)), std(samples.sigma_m(:))) };
add_text_to_figure('TL',str, text_size, 'latex')
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';

subplot(6,2,11)
h = histogram(samples.groupM(:), 31,'Normalization','probability'), xlabel('G_m'), box off
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';

% --

subplot(6,2,8)
h = histogram(samples.mu_c(:), 31,'Normalization','probability'), xlabel('\mu_c'), box off
%str=sprintf('mean = %2.3f \nvar = %2.3f', mean(samples.mu_c(:)), std(samples.mu_c(:)));
str={ sprintf(' Normal$$(%2.3f, %2.3f) $$',mean(samples.mu_c(:)), std(samples.mu_c(:))) };
add_text_to_figure('TL',str, text_size, 'latex')
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';

subplot(6,2,10)
h = histogram(samples.sigma_c(:), 31,'Normalization','probability'), xlabel('\sigma_c'), box off
%str=sprintf('mean = %2.3f \nvar = %2.3f', mean(samples.sigma_c(:)), std(samples.sigma_c(:)));
str={ sprintf(' Normal$$(%2.3f, %2.3f) $$',mean(samples.sigma_c(:)), std(samples.sigma_c(:))) };
add_text_to_figure('TL',str, text_size, 'latex')
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';

subplot(6,2,12)
h = histogram(samples.groupC(:), 31,'Normalization','probability'), xlabel('G_c'), box off
h.FaceColor=[0.5 0.5 0.5]; h.EdgeColor='none';


%%
% plot posterior predictive for group level
temp = size(samples.probeLogK);
probeLogK = reshape(samples.probeLogK, [temp(1)*temp(2), temp(3)]);

figure(1), subplot(2,1,1)
hold off
% many lines
loglog(exp(observed.probeReward), exp((probeLogK([1:1000],:))),'-','Color',[0 0 0 0.025]);
hold on
% mean
loglog(exp(observed.probeReward), exp(mean(probeLogK)),'k-','LineWidth',4)

% plot data
for n=1:max(study)
	%plot(observed.logreward(observed.study==n), observed.logk(observed.study==n),'ko-')
	loglog(exp(observed.logreward(observed.study==n)),...
		exp(observed.logk(observed.study==n)),'ko-','MarkerFaceColor','w');
	hold on
end

xlim([10^1 10^6])
ylim([10^-4 10^-1])

xlabel('reward (dollars)', 'Interpreter', 'latex')
ylabel('discount rate ($k$)', 'Interpreter', 'latex')

% -----------------
myExport([], [], ['priors'])







%% Extract mean and std of the params

fprintf('PRIORS FOR MAIN STUDY (mean and standard deviation (sigma) )\n')
fprintf('mu_m    ~ N(%2.3f, %2.3f)\n', mean(samples.mu_m(:)), std(samples.mu_m(:)))
fprintf('sigma_m ~ N(%2.3f, %2.3f)\n\n', mean(samples.sigma_m(:)), std(samples.sigma_m(:)))
fprintf('mu_c    ~ N(%2.3f, %2.3f)\n', mean(samples.mu_c(:)), std(samples.mu_c(:)))
fprintf('sigma_c ~ N(%2.3f, %2.3f)\n\n', mean(samples.sigma_c(:)), std(samples.sigma_c(:)))

% %%
% % plot posterior predictive for group level
% temp = size(samples.probeLogK);
% probeLogK = reshape(samples.probeLogK, [temp(1)*temp(2), temp(3)]);
% 
% figure(2)
% 
% % many lines
% loglog(exp(observed.probeReward), exp((probeLogK([1:100],:))),'-','Color',[0.8 0.8 0.8])
% hold on
% % mean
% loglog(exp(observed.probeReward), exp(mean(probeLogK)),'r-','LineWidth',4)
% 
% for n=1:max(study)
% 	%plot(observed.logreward(observed.study==n), observed.logk(observed.study==n),'ko-')
% 	loglog(exp(observed.logreward(observed.study==n)),...
% 		exp(observed.logk(observed.study==n)),'ko-')
% 	hold on
% end
% 
% xlim([10^1 10^6])
% ylim([10^-4 10^-1])
% 
% xlabel('reward (dollars)', 'Interpreter', 'latex')
% ylabel('discount rate ($k$)', 'Interpreter', 'latex')
% 
% myExport([], [], ['prior_visualise'])








% 
% xlabel('$\log$ (reward)', 'Interpreter', 'latex')
% ylabel('$\log$ ($k$)', 'Interpreter', 'latex')
% 
% axis equal
% set(gca,'XTick',[3:1:16])
% set(gca,'YTick',[-10:1:-2])
% grid on




