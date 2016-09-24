function fnamesWhiteList = excludeThese(fnames, exludeList)
% take a cell array of strings and remove entries in excludeList
fnamesWhiteList = setdiff(fnames, exludeList);
return
