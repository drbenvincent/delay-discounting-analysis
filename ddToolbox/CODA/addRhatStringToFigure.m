function addRhatStringToFigure(targetAxisHandle, rhat)

assert(isscalar(rhat))

subplot(targetAxisHandle)

str = sprintf('$$ \\hat{R} = %1.5f$$', rhat);


% TODO: This fails if we pan and zoom. Maybe add it at a fixed relative
% subplot position?
hText = addTextToFigure('T',str, 10, 'latex');

% visual warning if threshold exceeded
if rhat < RHAT_THRESHOLD()
	hText.BackgroundColor=[1 1 1 0.7];
else
	hText.BackgroundColor=[1 0 0 0.7];
end
end
