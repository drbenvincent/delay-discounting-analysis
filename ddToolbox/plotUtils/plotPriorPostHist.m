function [h]=plotPriorPostHist(priorSamples, posteriorSamples)

%% POSTERIOR
hPost=histogram(posteriorSamples(:),...
	'Normalization','pdf',...
	'EdgeColor','none',...
	'FaceColor',[0.2 0.2 0.2]);
axis tight
a=axis;


%% PRIOR
% if ~isempty(posteriorSamples)
% 	hold on
% 	hPrior=histogram(priorSamples(:),...
% 		'Normalization','pdf',...
% 		'EdgeColor','none',...
% 		'FaceColor',[0.8 0.8 0.8]);
% 	axis(a)
% else
% 	axis tight
% end
hold on
	hPrior=histogram(priorSamples(:),...
		'Normalization','pdf',...
		'EdgeColor','none',...
		'FaceColor',[0.8 0.8 0.8]);
if ~isempty(posteriorSamples)
	axis(a)
else
	axis tight
end

box off
set(gca,'TickDir','out')


%% return handle to figire
h=gcf;
return
