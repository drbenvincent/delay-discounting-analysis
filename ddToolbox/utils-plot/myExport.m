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
components = get_filename_components(p.Results);
save_path_no_extension = make_absolute_path_no_extension(components, p.Results.delimiter);
for format = p.Results.formats
	doExport(save_path_no_extension, format{:});
end


	function components = get_filename_components(p)
		components = {p.prefix, p.saveName, p.suffix};
		% remove empty components
		components = components(~cellfun('isempty',components));
	end

	function absolute_path_no_extension = make_absolute_path_no_extension(components, delimiter)
		saveFileName = strjoin( components, delimiter);
		absolute_path_no_extension = fullfile(p.Results.savePath, saveFileName);
	end

	function doExport(save_path_no_extension, format)
		set(gcf,'Color','w');

		% NOTE: Matlab seems to be incapable of exporting any figures with
		% transparency as vector graphics and will default to .png

		% This error handling is a bit long-winded, but:
		% - we don't want the program to halt just because of some error
		% with the external function export_fig
		% - but we do want some error information to be displayed
		try
			primary_figure_export_method(save_path_no_extension, format)
		catch ME
			fprintf('format = %s', format);
			warning('There was an error when calling ''export_fig''. Falling back to Matlab print command in order to avoid error.')
			try
				export_with_matlab_print_function(save_path_no_extension, format)
				disp('Sucessfully fell back to exporting with Matlab''s built-in print() command')
				disp('Here is summary of the error thrown by export_fig()')
				disp(ME)
			catch
				warning('Backup export plan with Matlab''s built-in print() command failed, so we have failed to export the requested figure :(')
				disp('Here is the original error thrown by export_fig')
				rethrow(ME)
			end
		end

		function primary_figure_export_method(save_path_no_extension, format)
			switch format
				case{'png'}
					export_fig(save_path_no_extension,'-png','-m2');
				case{'pdf'}
					export_fig(save_path_no_extension,'-pdf','-painters');
					%print('-opengl','-dpdf','-r2400', '-bestfit', [saveAs '.pdf'])
				case{'eps'}
					export_fig(save_path_no_extension,'-eps');
					%print('-depsc2', [saveAs '.eps'])
				case{'ps'}
					print('-depsc','-painters',[save_path_no_extension '.ps'])
				case{'svg'}
					print('-dsvg', [save_path_no_extension '.svg'])
				case{'fig'}
					hgsave(save_path_no_extension)
				otherwise
					warning('requested export format not recognised.')
			end
			fprintf('Figure saved: %s (%s)\n', save_path_no_extension, format);
		end

		function export_with_matlab_print_function(save_path_no_extension, format)
			format_matlab_sting = ['-d' format];
			print(save_path_no_extension, format_matlab_sting)
		end

	end

end
