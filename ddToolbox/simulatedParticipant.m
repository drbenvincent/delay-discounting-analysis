function [PB, R] = simulatedParticipant(lambda, sigma, k,  A, B, D)

% present value of B
VB = B ./ (1+k*D);

% probability of choosing B
PB = lambda + (1+2*lambda) * normcdf(VB-A, 0, sigma);

% simulate an actual response
if rand < PB
	R=1; % choose B
else
	R=0;
end

return