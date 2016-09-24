function myExport(savePath, saveName, varargin)
p = inputParser;
p.FunctionName = mfilename;
p.addRequired('savePath',@isstr);
p.addRequired('saveName',@isstr);
p.addParameter('prefix','',@ischar);
p.addParameter('suffix','',@isstr);
p.addParameter('formats',{'png'},@iscellstr);
p.addParameter('delimiter','-',@isstr);
p.parse(savePath, saveName, varargin{:});


% Algorithm
ensureFolderExists(p.Results.savePath);
saveAs = generateSaveAs(p);
doExport(saveAs);
fprintf('Figure saved: %s\n\n', saveAs);


	function saveAs = generateSaveAs(p)
		components = {p.Results.prefix, p.Results.saveName, p.Results.suffix};
		% remove empty components
		components = components(~cellfun('isempty',components));
		saveFileName = strjoin( components, p.Results.delimiter);
		saveAs = fullfile(p.Results.savePath, saveFileName);
	end


	function doExport(saveAs)
		set(gcf,'Color','w');
		
		% TODO: export in all formats defined in 'formats'
		
		% % .pdf
		% print('-opengl','-dpdf','-r2400', [saveAs '.pdf'])
		% .png
		export_fig(saveAs,'-png','-m4');
		% .fig
		%hgsave(saveAs)
	end

end
