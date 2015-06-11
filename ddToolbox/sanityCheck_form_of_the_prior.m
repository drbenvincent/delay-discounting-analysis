% What is tha appropriate prior

nSamples = 100000;

%% 1. Uniform prior over half life
hlSamples = unifrnd(1,1000,[nSamples 1]);
kSamples = 1./hlSamples;
subplot(3,2,1), hist(hlSamples,100)
subplot(3,2,2), hist(kSamples,100)

clear hlSamples kSamples
%% 2. Uniform prior over k
kSamples = unifrnd(10^-6,100,[nSamples 1]);
hlSamples = 1./kSamples;
subplot(3,2,3), hist(hlSamples,100)
subplot(3,2,4), hist(kSamples,100000), set(gca,'XScale','log')









%% 3. Normal distribution in log(k)

nSamples = 10000000;

m = 0.1; % desired mean
v = 2; % descired variance
% calculate mu and sigma parameters for lognormal
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));

Y = lognrnd(mu,sigma,[nSamples 1]);
clf
%hist(Y,100)

mean(Y)
var(Y)

% create log spaced bins for the histogram
bins = logspace(-8,6,50);
hist(Y,bins)
set(gca,'XScale','log')
xlim([10^-8 10^6])

% 
% %% 3. Uniform prior over log(k)
% kSamples = exprnd(1,[nSamples 1]);
% %hist(kSamples,10000), set(gca,'XScale','log')
% hist(kSamples,logspace(-5,5)), set(gca,'XScale','log')
% 
% x=linspace(0,200,1000);
% y = exppdf(x,1);
% plot(x,y), set(gca,'XScale','log')
% 
% 
% A=10^-5; B=10^1;
% n=1000;
% samples = exp(A + (B-A)*rand(1,n));
% hist(samples)
% 
% hist(samples,logspace(-5,2))