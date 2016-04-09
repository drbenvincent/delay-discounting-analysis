function prefix = getPrefixOfString(string,seperator)
  % returns the text at the start of a string before we hit a seperator.
  % Eg.
  % prefix = getPrefixOfString('bv-kirby27.txt','-')
  % will return 'bv'

  prefix = strtok(string, '-');
end
