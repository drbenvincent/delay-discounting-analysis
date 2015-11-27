function myExport(saveName, prefix, suffix)

%% set background as white
set(gcf,'Color','w');

%% Make sure folders exist
intialDir = cd;
if ~exist('figs', 'dir'), mkdir('figs'); end
cd('figs')

if numel(saveName)==0
	% don't save it in a folder
else
	if ~exist(saveName, 'dir'), mkdir('test'); end
	cd(saveName)
end

%% Export
saveFileName = [prefix saveName suffix];
% % .pdf
% print('-opengl','-dpdf','-r2400', [saveFileName '.pdf'])
% .png
export_fig(saveFileName,'-png','-m4')
% .fig
%hgsave(saveFileName)

%% finish up
fprintf('Figure saved: %s\n\n', saveFileName);
cd(intialDir)

return