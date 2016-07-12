function [outputMatrix, fields] = struct2Matrix(inputStruct)
  outputMatrix = [];
  fields = fieldnames(inputStruct);
  for n=1:numel(fields)
    outputMatrix = [ outputMatrix inputStruct.(fields{n})];
  end
end
