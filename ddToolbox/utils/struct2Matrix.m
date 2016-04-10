function [outputMatrix] = struct2Matrix(inputStruct)
  outputMatrix = [];
  fields = fieldnames(inputStruct);
  for n=1:numel(fields)
    %if isfield(obj.samples,fieldsToGet{n})
    outputMatrix = [ outputMatrix inputStruct.(fields{n})];
    %end
  end
end
