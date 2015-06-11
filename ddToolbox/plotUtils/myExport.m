function myExport(saveName, prefix, suffix)

%% set background as white
set(gcf,'Color','w')

%%
intialDir = cd;

mkdir('figs')
cd('figs')

if numel(saveName)==0
	% don't save it in a folder
else
	mkdir(saveName)
	cd(saveName)
end

saveFileName = [prefix saveName suffix];

%% Export
% .pdf
% print('-opengl','-dpdf','-r2400', [saveFileName '.pdf'])

%figName = [obj.saveFilename '-P' num2str(n)];

% .png
export_fig(saveFileName,'-png','-m4')

% .fig
hgsave(saveFileName)

cd(intialDir)

fprintf('Figure saved: %s\n\n', saveFileName);

return