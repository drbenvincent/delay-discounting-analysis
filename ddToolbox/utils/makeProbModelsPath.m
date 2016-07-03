function modelPath = makeProbModelsPath(modelType, samplerType)
modelPath = [probModelsLocation() '/' modelType '.' samplerType];
end