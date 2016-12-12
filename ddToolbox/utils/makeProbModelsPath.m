function modelPath = makeProbModelsPath(modelType, samplerType)
assert(~isempty(modelType))
model_filename_ext = [modelType '.' lower(samplerType)];
modelPath = which(model_filename_ext);
end