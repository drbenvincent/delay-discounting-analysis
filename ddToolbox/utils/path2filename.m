function IDnames = path2filename(fnames)
for n=1:numel(fnames)
	[~,IDnames{n},~] = fileparts(fnames{n}); % just get filename
end
end