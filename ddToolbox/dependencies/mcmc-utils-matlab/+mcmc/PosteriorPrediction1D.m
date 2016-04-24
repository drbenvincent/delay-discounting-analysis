classdef PosteriorPrediction1D < handle
	%% PosteriorPrediction1D

	properties
		variableNames
		fh
		xInterp
		%samples
		Y
		nSamples
		samples
		ciType
		nExamples
		pointEstimateType
		pointEstimate
		shouldPlotData
		xData, yData
		ciWidth
		h % a structure containing handles to figure and plot objects
	end

	properties(Access = protected)
	end


	methods

		% Class constructor
		function obj=PosteriorPrediction1D(fh, varargin)

			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('fh',@(x) isa(x,'function_handle'));
			p.addParameter('xInterp',[],@isvector);
			p.addParameter('samples',[],@ismatrix);
			p.addParameter('variableNames',{},@iscellstr);
			p.addParameter('ciType','examples',@(x)any(strcmp(x,{'examples','range','probMass'})));
			p.addParameter('nExamples',100,@isscalar);
			p.addParameter('ciWidth',0.95,@isscalar);
			p.addParameter('pointEstimateType','mean',@isstr);
			p.addParameter('shouldPlotData',true,@islogical);
			p.addParameter('xData',[],@isvector);
			p.addParameter('yData',[],@isvector);
			p.parse(fh, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			obj.nSamples= size(obj.samples,1);

			% predefine handles for point estimates
			obj.h.hPointEst=[];
			
			% Calculate point estimate
			warning('DEAL WITH SPECIFIED POINT ESTIMATE TYPE')
			obj.pointEstimate = mean(obj.samples);

			% High-level plotting commands
			switch obj.ciType
				case{'examples'}
					obj.plotExamples();
				case{'range'}
					obj.plotCI();
				case{'probMass'}
					obj.plotProbMass();
			end
			obj.plotPointEstimate();
			obj.plotData();
		end

		function evaluateFunction(obj,ExamplesToPlot)
			% Evaluate the 1D function for the x-values specified and for
			% each of the MCMC samples. This will result in a matrix with:
			% rows = number of x-axis values
			% cols = number of MCMC samples
			fprintf('Evaluating the function over %d MCMC samples...\n',...
				numel(ExamplesToPlot));

			if isempty(ExamplesToPlot)
				ExamplesToPlot = [1:obj.nSamples];
			end

			try
				% If the function handle can deal with vectorised inputs
				% then this should compute much faster
				%obj.Y = obj.fh(obj.xInterp, obj.samples(:,:))';
				obj.Y = obj.fh(obj.xInterp, obj.samples(ExamplesToPlot,:))';
			catch
				% but if that fails, fall back on looping through mcmc
				% samples
				warning('*** SLOWNESS WARNING ***')
				warning('Recommend writing your function in a way that can handle vectorised inputs')
				Y = zeros(numel(obj.xInterp),numel(ExamplesToPlot));
				for s=1:numel(ExamplesToPlot)
					obj.Y(:,s) = obj.fh(obj.xInterp, obj.samples(ExamplesToPlot(s),:));
				end
			end

		end


		function obj = plotPointEstimate(obj)
			% Plot a single curve with the single set of parameters. These
			% might correspond to the mode of the MCMC parameters, for
			% example.
			% Calculate the y-values
			YpointEstimate = obj.fh(obj.xInterp, obj.pointEstimate);
			% plot the point estimate
			hold on
			hPointEst = plot(obj.xInterp, YpointEstimate,'k-', 'LineWidth', 3);
			% concatenate handle onto a list, so that we can plot multiple
			% point estimates and have handles to each
			if numel(obj.h.hPointEst)==0
				obj.h.hPointEst = hPointEst;
			else
				obj.h.hPointEst = [obj.h.hPointEst hPointEst];
			end
		end


		function obj = plotExamples(obj)
			% Plots a random set of example functions, each one corresponds
			% to a particular MCMC sample.
			% If we've asked for more examples, than MCMC samples, then
			% just plot all.
			if obj.nExamples > obj.nSamples
				obj.nExamples = obj.nSamples;
			end
			% shuffle the deck and pick the top nExamples
			shuffledExamples = randperm(obj.nSamples);
			ExamplesToPlot = shuffledExamples([1:obj.nExamples]);
			% Evaluate the function just for these examples
			obj.evaluateFunction(ExamplesToPlot);
			hExamples = plot(obj.xInterp, obj.Y,'-',...
				'Color',[0.5 0.5 0.5 0.1]);
% 			hExamples = plot(obj.xInterp, obj.Y(:,ExamplesToPlot),'k-');
			obj.h.Axis		= gca;
			obj.h.hExamples = hExamples;
			formatAxes(obj)
		end

		function obj = plotCI(obj)
			obj.evaluateFunction([1:obj.nSamples]);
			% Plots shaded 95%
			vals = [(1-0.95)/2 1-((1-0.95)/2)].*100;
			CI = prctile(obj.Y',vals);
			% draw the shaded error bar zone
			x = [obj.xInterp,fliplr(obj.xInterp)];
			y = [CI(2,:),fliplr(CI(1,:))];
			hCI =patch(x,y,[0.8 0.8 0.8]);
			hCI.EdgeColor='none';
			% save handle to CI
			obj.h.hCI = hCI;
			formatAxes(obj)
		end

		function obj = plotProbMass(obj)
			% Plots the posterior predictive distribution in the form of a
			% 2D probability mass function.
			obj.evaluateFunction([1:obj.nSamples]);
			yi = linspace( min(obj.Y(:)), max(obj.Y(:)), 100);
			[PM]=calcProbabilityMass(obj,yi);
			hProbMass=imagesc(obj.xInterp, yi, PM);
			axis xy
			% save handle to prob mass
			obj.h.hExamples = hProbMass;
			formatAxes(obj)
		end

		function obj = plotData(obj)
			hold on
			if isempty(obj.xData), return, end
			if isempty(obj.yData), return, end
			if ~obj.shouldPlotData, return, end
			hData=plot(obj.xData,obj.yData,...
				'o',...
				'MarkerSize',8,...
				'MarkerEdgeColor','k',...
				'MarkerFaceColor','w');
			% save handle to data points
			obj.h.hData = hData;
			formatAxes(obj)
		end

	end

end







%% Private functions

function [PM]=calcProbabilityMass(obj,yi)
% The matrix obj.Y has a number of rows equal to the number of x-axis
% values that we are evaluating the function over, and has a number of
% columns equal to the number of MCMC samples provided. What we do here is
% to loop over the x-values and convert the set of samples into a
% probability mass function by use of the hist function. We do this for the
% y values specified in the vector yi.
display('Calculating probability mass...')
obj.evaluateFunction([1:obj.nSamples]);
% preallocate
PM = zeros(size(obj.Y,1), numel(yi));
% loop over x-values, calculating posterior mass for the corresponding
% samples
for x=1:size(obj.Y,1)
	PM(x,:) = hist( obj.Y(x,:) , yi );
	% scale so the max of each column (x-value) is equal to 1
	PM(x,:) =PM(x,:) / max(PM(x,:));
end
PM=PM'; % transpose
end


function formatAxes(obj)
if ~isempty(obj.xData)
	xlim([min(obj.xData) max(obj.xData)])
end
% axes on top layer
ah=gca; ah.Layer='top';
axis square
box off
xlabel(obj.variableNames{1},'Interpreter','latex')
ylabel(obj.variableNames{2},'Interpreter','latex')
end
