function IDnames = path2participantID(fnames)
for n=1:numel(fnames)
    parts = strsplit(fnames{n},'-');
    IDnames{n} = parts{1};
	%condition = parts{2};
end
end
