function plotGroupLevelStuff(obj)
	group_level_prior_variables = cellfun(...
		@getPriorOfVariable,...
		obj.varList.groupLevel,...
		'UniformOutput',false );




	% PSYCHOMETRIC PARAMS
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	figPsychometricParamsHierarchical(obj.mcmc, obj.data)
	myExport('PsychometricParams',...
		'saveFolder', obj.saveFolder,...
		'prefix', obj.modelType)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~







	% TRIPLOT
	import mcmc.*
	posteriorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.groupLevel);
	priorSamples = obj.mcmc.getSamplesAsMatrix(group_level_prior_variables);

	figure(87)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	TriPlotSamples(posteriorSamples,...
		obj.varList.groupLevel,...
		'PRIOR', priorSamples,...
		'pointEstimateType',obj.pointEstimateType);
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	myExport('GROUP-triplot',...
		'saveFolder', obj.saveFolder,...
		'prefix', obj.modelType)




	% GROUP (UNSEEN PARTICIPANT) PLOT

	% strip the '_group' off of variablenames
	for n=1:numel(obj.varList.groupLevel)
		temp=regexp(obj.varList.groupLevel{n},'_','split');
		groupLevelVarName{n} = temp{1};
	end
	% 			% get point estimates. TODO: this can be a specific method in mcmc.
	% 			for n=1:numel(obj.varList.groupLevel)
	% 				pointEstimate.(groupLevelVarName{n}) =...
	% 					obj.mcmc.getStats('mean', obj.varList.groupLevel{n});
	% 			end

	[pSamples] = obj.mcmc.getSamples(obj.varList.groupLevel);
	% flatten
	for n=1:numel(obj.varList.groupLevel)
		pSamples.(obj.varList.groupLevel{n}) = vec(pSamples.(obj.varList.groupLevel{n}));
	end
	% rename
	pSamples = renameFields(...
		pSamples,...
		obj.varList.groupLevel,...
		groupLevelVarName);


	% TODO ??????????????????
	opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
	opts.maxD		= max(obj.data.observedData.DB(:));
	% ???????????????????????

	% 			% get group level pointEstimates
	% 			pointEstimates = obj.mcmc.getParticipantPointEstimates(1, obj.varList.groupLevel);
	% 			pointEstimates = renameFields(...
	% 				pointEstimates,...
	% 				obj.varList.groupLevel,...
	% 				groupLevelVarName);

	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	figure
	obj.plotFuncs.participantFigFunc(pSamples,...
		obj.pointEstimateType,...
		'opts', opts)
	latex_fig(16, 18, 4)
	myExport('GROUP',...
		'saveFolder', obj.saveFolder,...
		'prefix', obj.modelType)
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
end
