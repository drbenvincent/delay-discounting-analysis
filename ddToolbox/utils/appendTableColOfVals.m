function pTable = appendTableColOfVals(pTable, n)
ID = ones( height(pTable), 1) * n;
pTable = [pTable table(ID)];
end