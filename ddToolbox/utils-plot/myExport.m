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
for format = p.Results.formats
	doExport(saveAs, format{:});
end
fprintf('Figure saved: %s\n\n', saveAs);


	function saveAs = generateSaveAs(p)
		components = {p.Results.prefix, p.Results.saveName, p.Results.suffix};
		% remove empty components
		components = components(~cellfun('isempty',components));
		saveFileName = strjoin( components, p.Results.delimiter);
		saveAs = fullfile(p.Results.savePath, saveFileName);
	end


	function doExport(saveAs, format)
		set(gcf,'Color','w');
		
		% NOTE: Matlab seems to be incapable of exporting any figures with
		% transparency as vector graphics and will default to .png
		switch format
			case{'png'}
				export_fig(saveAs,'-png','-m2');
			case{'pdf'}
				export_fig(saveAs,'-pdf','-painters');
				%print('-opengl','-dpdf','-r2400', '-bestfit', [saveAs '.pdf'])
			case{'eps'}
				export_fig(saveAs,'-eps');
				%print('-depsc2', [saveAs '.eps'])
			case{'ps'}
				print('-depsc','-painters',[saveAs '.ps'])
			case{'svg'}
				print('-dsvg', [saveAs '.svg'])
			case{'fig'}
				hgsave(saveAs)
		end
	end

end
