function plotYMCMC(x,Y)
%
% we are given a vector of x-values
% For each x-value we have many MCMC samples
%
% calculate...


semilogx(x, mean(Y))
hold on

Y = prctile(Y,[5 95]);
semilogx(x,Y,'k--')

a=axis;
plot(a(3), expt.B)
return


