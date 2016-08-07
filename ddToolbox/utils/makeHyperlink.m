function hyperlink = makeHyperlink(text, codeToRun)
assert(ischar(text))
assert(ischar(codeToRun))
codeToRun = ['matlab: ' codeToRun];
hyperlink = sprintf('<a href="%s">%s</a>', codeToRun, text);
return
