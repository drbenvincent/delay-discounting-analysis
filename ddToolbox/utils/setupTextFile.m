function [fid, fname] = setupTextFile(savePath, filename)
    ensureFolderExists(savePath)
    fname = fullfile(savePath,filename);
    fid=fopen(fname,'w');
    assert(fid~=-1)
return
