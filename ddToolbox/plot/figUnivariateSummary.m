function figUnivariateSummary(alldata)
% figUnivariateSummary
% create a multi-panel figure (one subplot per variable), each
% comprising of univariate summary stats for all participants.

% % We are going to add on group level inferences to the end of the
% % list. This is because the group-level inferences an be
% % seen as inferences we can make about an as yet unobserved
% % participant, in the light of the participant data available thus
% % far.

figure(34)

variables = alldata.variables;
participantNames = alldata.IDnames;

% just get the participant ID. We assume the filenames are coded as:
% <ID>-<other information>.txt
participantNames = getPrefixOfString(participantNames,'-');

for v = 1:numel(variables)
	subplot(numel(variables),1,v)
	plotErrorBars({participantNames{:}},...
		alldata.(variables{v}).pointEstVal,...
		alldata.(variables{v}).hdi,...
		variables{v});
	a=axis;
	axis([0.5 a(2)+0.5 a(3) a(4)]);
end

%% Scale width of figure
screen_size = get(0,'ScreenSize');
fig_width = min(screen_size(3), 100+numel(participantNames)*20);
set(gcf,'Position',[100 200 fig_width 1000])

%% Export
%latex_fig(16, 5, 5)
myExport('UnivariateSummary',...
    'saveFolder',alldata.saveFolder,...
    'suffix', alldata.modelType)
end