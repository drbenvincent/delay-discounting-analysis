function hyperlink = displayClickableLinkToCommandWindow(text, codeToRun)
% printLink('Do something', 'a=3')

codeToRun = ['matlab: ' codeToRun];
hyperlink = sprintf('<a href="%s">%s</a>', codeToRun, text);
disp(hyperlink)
return