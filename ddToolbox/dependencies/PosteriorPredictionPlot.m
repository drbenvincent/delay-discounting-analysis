classdef PosteriorPredictionPlot < handle
	%% PosteriorPredictionPlot
	% An object to plot posterior predictions for 1D functions. This object
	% takes plots a user-specified function
	%
	% fh	= handle to the function
	% x		= range of values to evaluate the function over
	% params= each row is a set of parameters corresponding to one MCMC
	% sample. Each column is a parameter which is used in the
	% user-specified 1D function.
	%
	% METHODS
	% PosteriorPredictionPlot() % constructor
	% plotExamples() plots a few example curves drawn at random
	% plotCI() plots a shaded confidence region
	% plotProbMass() plots 2D image of probability mass
	% plotData() plots data points
	%
	%
	% Originally written by Ben Vincent
	% https://github.com/drbenvincent
	
	% public properties
	properties
		
	end
	
	% read-only properties
	properties(GetAccess='public', SetAccess='private')
		fh
		x
		params
		Y
		nSamples
		h % a structure containing handles to figure and  plot objects
	end
	
	% protected, i.e. not visible from outside
	properties(Access = protected)
	end
	
	
	methods
		
		% Class constructor
		function obj=PosteriorPredictionPlot(fh, x, params)
			% params is of size [nSamples x nParams]
			obj.fh		= fh;				% handle to our 1D function
			obj.x		= x;				% x-axis values to evaluate
			obj.params	= params;			
			obj.nSamples= size(params,1);
			
			% THIS IS AN EXPENSIVE FUNCTION TO EVALUATE ~~~~~~~~~~~~~~~~~~~
			%obj = obj.evaluateFunction();
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
			% By default we do not plot anything when the object is
			% constrcuted. You can call one of the plot methods to build
			% the plot how you like it.
			
			% predefine handles for point estimates
			obj.h.hPointEst=[];
		end
		
		function obj = evaluateFunction(obj,ExamplesToPlot)
			% Evaluate the 1D function for the x-values specified and for
			% each of the MCMC samples. This will result in a matrix with:
			% rows = number of x-axis values
			% cols = number of MCMC samples
			fprintf('Evaluating the function over %d MCMC samples...\n',...
				numel(ExamplesToPlot));
			
			% if ExamplesToPlot is empty (ie equal to []) then assume we want to
			% evaluate over all values
			if isempty(ExamplesToPlot)
				ExamplesToPlot = [1:obj.nSamples];
			end
			
			try
				% If the function handle can deal with vectorised inputs
				% then this should compute much faster
				%obj.Y = obj.fh(obj.x, obj.params(:,:))';
				obj.Y = obj.fh(obj.x, obj.params(ExamplesToPlot,:))';
			catch
				% but if that fails, fall back on looping through mcmc
				% samples
				warning('*** SLOWNESS WARNING ***')
				display('Recommend writing your function in a way that can handle vectorised inputs')
				for s=1:obj.nSamples
					obj.Y(:,s) = obj.fh(obj.x, obj.params(s,:));
				end
			end

		end
		
		%% PLOTTING METHODS
		
		function obj = plotPointEstimate(obj,params)
			% Plot a single curve with the single set of parameters. These
			% might correspond to the mode of the MCMC parameters, for
			% example.
			
			% Calculate the y-values
			YpointEstimate = obj.fh(obj.x, params);
			
			% plot the point estimate
			hold on
			hPointEst = plot(obj.x, YpointEstimate,'k-', 'LineWidth', 3);
			
			% concatenate handle onto a list, so that we can plot multiple
			% point estimates and have handles to each
			if numel(obj.h.hPointEst)==0
				obj.h.hPointEst = hPointEst;
			else
				obj.h.hPointEst = [obj.h.hPointEst hPointEst];
			end
		end
		
		
		function obj = plotExamples(obj,nExamples)
			% Plots a random set of example functions, each one corresponds
			% to a particular MCMC sample.
			
			% if we've asked for more examples, than MCMC samples, then
			% just plot all.
			if nExamples > obj.nSamples
				nExamples = obj.nSamples;
			end
			
			% shuffle the deck and pick the top nExamples
			shuffledExamples = randperm(obj.nSamples);
			ExamplesToPlot = shuffledExamples([1:nExamples]);
			
			
			% Evaluate the function just for these examples
			obj.evaluateFunction(ExamplesToPlot);

			hExamples = plot(obj.x, obj.Y,'-',...
				'Color',[0.5 0.5 0.5 0.1]);
			
% 			hExamples = plot(obj.x, obj.Y(:,ExamplesToPlot),'k-');
			
			obj.h.Axis		= gca;
			obj.h.hExamples = hExamples;
			
			formatPlot(obj)
		end
		
		function obj = plotCI(obj,ci)
			
			obj = obj.evaluateFunction([1:obj.nSamples]);
			
			% Plots shaded 95%
			CI = prctile(obj.Y',ci);
			
			% draw the shaded error bar zone
			x =[obj.x,fliplr(obj.x)];
			y =[CI(2,:),fliplr(CI(1,:))];
			hCI =patch(x,y,[0.8 0.8 0.8]);
			hCI.EdgeColor='none';
		
			% save handle to CI
			obj.h.hCI = hCI;
			
			formatPlot(obj)
		end
		
		function obj = plotProbMass(obj,yi)
			% Plots the posterior predictive distribution in the form of a
			% 2D probability mass function.
			
			[PM]=calcProbabilityMass(obj,yi);
			
			hProbMass=imagesc(obj.x, yi, PM);
			axis xy
			
			% save handle to prob mass
			obj.h.hExamples = hProbMass;
			
			formatPlot(obj)
		end
		
		function obj = plotData(obj,xdata, ydata)
			% Plots, as points, the provided x/y data.
			
			hData=plot(xdata,ydata,'.');
			hData.MarkerSize = 5^2;
		
			% save handle to data points
			obj.h.hData = hData;
			
			formatPlot(obj)
		end
		
		
	end % methods
	
end % classdef







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


function formatPlot(obj)
%axis square 
box off
xlim([min(obj.x) max(obj.x)])

% axes on top layer
ah=gca; ah.Layer='top';
end

