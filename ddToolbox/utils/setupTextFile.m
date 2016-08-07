function [fid, fname] = setupTextFile(savePath, filename)
    ensureFolderExists(fullfile('figs',savePath)) %<--- TODO remove hard coding of 'figs'?
    fname = fullfile('figs',savePath,filename);
    fid=fopen(fname,'w');
    assert(fid~=-1)
return
