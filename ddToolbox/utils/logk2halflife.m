function halflife = logk2halflife(logk)
%LOGK2HALFLIFE
% Calculate the half life for a given log discount rate. WARNING: this may
% not be valid for anything other than the 1-parameter discount rate
% function.
halflife = 1./exp(logk);
return