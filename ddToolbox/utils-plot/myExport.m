function myExport(saveName, varargin)
p = inputParser;
p.FunctionName = mfilename;
p.addRequired('saveName',@isstr);
p.addParameter('prefix','',@(x) @isstr(x) || @iscellstr(x));
p.addParameter('suffix','',@isstr);
p.addParameter('saveFolder','',@isstr);
p.addParameter('formats',{'png'},@iscellstr);
p.addParameter('delimiter','-',@isstr);
p.parse(saveName, varargin{:});

%% saveAs
components = {p.Results.prefix, p.Results.saveName, p.Results.suffix};
% remove empty components
components = components(~cellfun('isempty',components));
saveFileName = strjoin( components, p.Results.delimiter);
% [p.Results.prefix...
%     p.Results.delimiter...
%     p.Results.saveName...
%     p.Results.delimiter...
%     p.Results.suffix];
saveAs = fullfile('figs', p.Results.saveFolder, saveFileName);
ensureFolderExists(fullfile('figs', p.Results.saveFolder))

%% do the exporting
% set background as white
set(gcf,'Color','w');

% TODO: export in all formats defined in 'formats'

% % .pdf
% print('-opengl','-dpdf','-r2400', [saveAs '.pdf'])
% .png
export_fig(saveAs,'-png','-m4')
% .fig
%hgsave(saveAs)

%% finish up
fprintf('Figure saved: %s\n\n', saveAs);

return
