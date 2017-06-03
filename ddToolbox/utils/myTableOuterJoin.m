function C = myTableOuterJoin(A, B)

% 1. Add RowNames as a column in both tables
A.rownames = A.Properties.RowNames;
B.rownames = B.Properties.RowNames;

% 2. Now do outerjoin
C = outerjoin(A, B, 'MergeKeys',true);

% 3. Remove 'rownames' column and use it as RowNames
C.Properties.RowNames = C.rownames;
C.rownames = [];

end