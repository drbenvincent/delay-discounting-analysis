function [fid, fname] = setupTextFile(saveFolder, filename)
    ensureFolderExists(fullfile('figs',saveFolder)) %<--- TODO remove hard coding of 'figs'?
    fname = fullfile('figs',saveFolder,filename);
    fid=fopen(fname,'w');
    assert(fid~=-1)
return
