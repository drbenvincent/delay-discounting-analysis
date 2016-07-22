function sampler = samplerFactory(samplerType, modelFile)

switch samplerType
	case{'jags'}
		sampler = MatjagsWrapper(modelFile);
		
	case{'stan'}
		sampler = MatlabStanWrapper(modelFile);
end