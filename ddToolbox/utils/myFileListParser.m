function files = myFileListParser(myFolder, nArgsIn, myCellArray)

start_folder=cd;

cd(myFolder)

if nArgsIn==0
	% no files provided therefore ask for files in a GUI
	
	
	% navigate to defult folder (if it exists) --
	%cd(myFolder)
	% -------------------------------------------
	[files,PathName] = uigetfile('*.txt','Select the data file(s)',...
		'MultiSelect','on');
	
	
elseif nArgsIn==2
	% loop through files listed in the cell array
	files=myCellArray{1};
	
	% if we only had one filename, then fine, but if that was:
	% "bv*"
	% then we will interpret this as wanting to analyse all available files
	% starting with "bv"
	if numel(files)==1
		switch files{1}(end)
			case{'*'}
				% find all files starting with whatever preceeded '*'
				pref = files{1}(1:end-1);
				%cd(myFolder)
				
				%temp=dir( [files{1} '.txt'] );
				temp=dir( files{1} );
				files = {temp.name};
				
		end
	end
	
end

cd(start_folder)

return