function modelPath = makeProbModelsPath(modelType, samplerType)
assert(~isempty(modelType))
modelPath = [probModelsLocation() '/' modelType '.' samplerType];
end