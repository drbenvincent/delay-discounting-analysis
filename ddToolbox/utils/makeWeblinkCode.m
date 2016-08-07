function weblinkCode = makeWeblinkCode(url)
assert(ischar(url))
weblinkCode = sprintf('web(''%s'')', url);
return
