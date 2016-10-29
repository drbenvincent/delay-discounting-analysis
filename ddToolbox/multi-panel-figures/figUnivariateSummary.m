function figUnivariateSummary(alldata)
% figUnivariateSummary
% create a multi-panel figure (one subplot per variable), each
% comprising of univariate summary stats for all participants.

% % We are going to add on group level inferences to the end of the
% % list. This is because the group-level inferences an be
% % seen as inferences we can make about an as yet unobserved
% % participant, in the light of the participant data available thus
% % far.

figure(34), clf

%% DATA PREP
participantNames = makeParticipantNames();

%% CREATE SUBPLOTS
N = numel(variables);
subplot_handles = create_subplots(N, 'col');

%% APPLY THE PLOTS TO THE SUBPLOTS
%arrayfun(int_plot_func(), [1:N])
for n = 1:numel(variables)
	subplot( subplot_handles(n) )
	int_plot_func(n)
end

%% Scale width of figure
screen_size = get(0,'ScreenSize');
fig_width = min(screen_size(3), 100+numel(participantNames)*20);
set(gcf,'Position',[100 200 fig_width 1000])

if alldata.shouldExportPlots
	myExport(alldata.savePath,...
		'UnivariateSummary',...
		'suffix', alldata.modelFilename)
end

	function participantNames = makeParticipantNames()
		variables = alldata.variables;
		participantNames = alldata.filenames;
		
		% just get the participant ID. We assume the filenames are coded as:
		% <ID>-<other information>.txt
		participantNames = getPrefixOfString(participantNames,'-');
	end

	function int_plot_func(n)
		subplot( subplot_handles(n) )
		N = numel(alldata.(variables{n}).pointEstVal);
		plotErrorBars({participantNames{[1:N]}},... 
			alldata.(variables{n}).pointEstVal,...
			alldata.(variables{n}).hdi,...
			variables{n});
		a=axis;
		axis([0.5 a(2)+0.5 a(3) a(4)]);
	end
end