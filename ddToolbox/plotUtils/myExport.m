function myExport(saveName, prefix, suffix)

% set background as white
set(gcf,'Color','w');

% As it stands, we are going to save the current figure in relative
% location:
% /figs/{saveName}
saveLocation = fullfile('figs',saveName);
if ~exist(saveLocation, 'dir'), mkdir(saveLocation); end

saveFileName = [prefix saveName suffix];
saveAs = fullfile(saveLocation, saveFileName);
% % .pdf
% print('-opengl','-dpdf','-r2400', [saveAs '.pdf'])
% .png
export_fig(saveAs,'-png','-m4')
% .fig
%hgsave(saveAs)

% finish up
fprintf('Figure saved: %s\n\n', saveAs);

return