classdef Stochastic < handle
	
	properties
		name
		mean, median, mode
		samples
	end
	
	properties (Access = private)
		true
		
		
		
		plot_options
		
		priorSamples %priorCol
		XRANGE
		xi
		density
		%shouldPlot
		%killYAxis
		%patchProperties
		
		%xLabel,
		
		pointEstimateType
		shouldPlotPointEstimate
		%col
		HDI
		%plotHDI
		%plotStyle
		N
		%FaceAlpha
		%axisSquare
	end
	
	properties (GetAccess = public, SetAccess = protected)
		
	end
	
	methods
		
		function obj = Stochastic(name, varargin)
			
			obj.name = name;
			
			obj.set_plot_options(varargin{:});
			
% 			p = inputParser;
% 			p.FunctionName = mfilename;
% 			p.addRequired('name',@ischar);
% 			p.parse(posteriorSamples, varargin{:});
			
			% parse plot_opts
			
%			p.addParameter('priorSamples',[],@isvector);
% 			p.addParameter('xLabel','',@isstr);
% 			p.addParameter('plotStyle','kde',@(x)any(strcmp(x,{'hist','kde'})))
% 			p.addParameter('shouldPlot',true,@islogical);
% 			p.addParameter('killYAxis',true,@islogical);
% 			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
% 			p.addParameter('col',[0.6 0.6 0.6],@isvector);
% 			p.addParameter('pointEstimateType','mode', @(x)any(strcmp(x,{'mean','median','mode'})));
% 			p.addParameter('shouldPlotPointEstimate',false,@islogical);
% 			p.addParameter('FaceAlpha',0.2,@isscalar);
% 			p.addParameter('patchProperties',{'FaceAlpha',0.8},@iscell);
% 			p.addParameter('plotHDI',true,@islogical);
% 			p.addParameter('axisSquare',false,@islogical);
% 			p.parse(posteriorSamples, varargin{:});
% 			% add p.Results fields into obj
% 			fields = fieldnames(p.Results);
% 			for n=1:numel(fields)
% 				obj.(fields{n}) = p.Results.(fields{n});
% 			end
			
% 			obj.N = size(obj.samples,2);
% 			% obj.XRANGE = [min(posteriorSamples) max(posteriorSamples)];
% 			% obj.YRANGE = [min(priorSamples) max(priorSamples)];
% 			
% 			if isempty(posteriorSamples) || any(isnan(posteriorSamples(:)))
% 				warning('invalid samples passed into function')
% 				return
% 			end
% 			% Calculate stats upon construction
% 			obj.mean = mean(obj.samples);
% 			obj.median = median(obj.samples);
% 			obj.calculateDensityAndPointEstimates();
% 			obj.HDI = mcmc.HDIofSamples(obj.samples, 0.95);
% 			if p.Results.shouldPlot
% 				obj.plot();
% 			end
			
		end
		
		function obj = addSamples(obj, samples)
			obj.samples = samples;
			
			% Calculate stats upon addition of samples
			obj.mean = mean(obj.samples);
			obj.median = median(obj.samples);
			obj.calculateModeAndDensity();
			obj.HDI = mcmc.HDIofSamples(obj.samples, 0.95);

		end
		

		
		function [pointEstimate] = getPointEstimate(obj)
			pointEstimate = obj.(obj.pointEstimateType);
		end
		
		function plot(obj)
			switch obj.plot_options.plotStyle
				case{'hist'}
					h = obj.plotHist();
				case{'kde'}
					h = obj.plotDensity();
			end
			obj.formatAxes();
			obj.plotPointEstimate();
			obj.panOptions();
		end
		
		
		function [HDI] = calculateHDI(obj, credibilityMass)
			% Directly translated from code in:
			% Kruschke, J. K. (2015). Doing Bayesian Data Analysis: A Tutorial with R,
			% JAGS, and Stan. Academic Press.
			
			assert(credibilityMass > 0 && credibilityMass < 1,...
				'credibilityMass must be a between 0-1.')
			
			sorted_samples = sort(obj.samples(:));
			ciIdxInc = floor( credibilityMass * numel( sorted_samples ) );
			nCIs = numel( sorted_samples ) - ciIdxInc;
			
			ciWidth=zeros(nCIs,1);
			for n =1:nCIs
				ciWidth(n) = sorted_samples( n + ciIdxInc ) - sorted_samples(n);
			end
			
			[~, minInd] = min(ciWidth);
			HDImin	= sorted_samples( minInd );
			HDImax	= sorted_samples( minInd + ciIdxInc);
			HDI		= [HDImin HDImax];
		end
		
		
		function pointEstimate = extractThetaPointEstimates(obj, pointEstimateType)
			if numel(obj)==1
				% one Stochastic object
				pointEstimate = obj.(pointEstimateType);
			else
				% array of stochastics
				for n=1:numel(obj)
					pointEstimate(:,n) = obj(n).(pointEstimateType);
				end
				pointEstimate = pointEstimate';
			end
		end
		
		
		function samples = extractTheseThetaSamples(obj, examplesToPlot)
			if numel( obj )==1
				% one Stochastic object
				samples = obj.samples(examplesToPlot);
			else
				% array of stochastics
				for n=1:numel(obj)
					samples(:,n) = obj(n).samples(examplesToPlot);
				end
				samples = samples';
			end
		end
		
		function nSamples = howManySamples(obj)
			if numel( obj )==1
				% one Stochastic object
				nSamples = numel(obj(1).samples);
			else
				% array of stochastics
				for n=1:numel(obj)
					nSamples(n) = numel(obj(1).samples);
				end
				% TODO: check nSamples are the same for all objects in array
				nSamples = nSamples(1);
			end
		end
		
	end
	
	methods
% 		function samples = get.samples(obj)
% 			samples = obj.samples;
% 		end
	end
	
	methods (Access = private)
		
		function panOptions(obj)
			ax = gca;
			h = pan;
			setAxesPanMotion(h,ax,'horizontal');
		end
		
		function obj = calculateModeAndDensity(obj)
			if any(isnan(obj.samples))
				obj.mode = [];
				obj.density = [];
			else
				obj.xi = linspace( min(obj.samples(:)), max(obj.samples(:)), 1000);
				obj.xi = [obj.xi(1) obj.xi obj.xi(end)]; % fix to avoid plotting artifacts
				obj.density = ksdensity(obj.samples(:), obj.xi);
				obj.mode = obj.xi( argmax(obj.density) );
				
				obj.density([1,end])=0; % fix to avoid plotting artifacts
			end
		end
		
		function h = plotHist(obj)
			hold on
			%for n=1:obj.N
			try
				h = histogram(obj.samples(:),...
					'Normalization','pdf',...
					'EdgeColor','none',...
					'FaceColor',obj.plot_options.col,...
					'FaceAlpha',obj.plot_options.FaceAlpha);
			catch
				% backward compatability
				[N,X] = hist(obj.samples(:));
				N = N./sum(N);
				h = stairs(X,N,'k-');
			end
			%end
			axis tight
		end
		
		
		function plotDensity(obj)
			hold on
			for n=1:obj.N
				h(n)= fill(obj.xi,...
					obj.density(:,n),...
					obj.col,...
					'EdgeColor','none',...
					'FaceAlpha',obj.FaceAlpha);
				% apply plot options to patch
				set(h(n), obj.patchProperties{:});
			end
			
		end
		
		
		function plotPointEstimate(obj)
			if ~obj.shouldPlotPointEstimate, return, end
			a = axis;
			for n=1:obj.N
				x = [obj.(obj.pointEstimateType)(n) obj.(obj.pointEstimateType)(n)];
				y = [a(3) a(4)];
				h = line(x,y);
				h.Color = 'k';
			end
		end
		
		
		function formatAxes(obj)
			
% 			if obj.plot_options.killYAxis
% 				mcmc.removeYaxis()
% 			end
% 			
% 			if obj.plot_options.plotHDI
% 				for n=1:obj.N
% 					mcmc.showHDI(obj.samples(:,n))
% 				end
% 			end
			
			box off
			axis tight
			if obj.plot_options.axisSquare, axis square, end
			set(gca,'TickDir','out')
			set(gca,'Layer','top');
			xlabel(obj.name, 'interpreter', 'latex')
		end
		
		
		
		function obj = set_plot_options(obj, varargin )
			p = inputParser;
			p.addParameter('plotStyle','hist',@(x)any(strcmp(x,{'hist','kde'})))
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('killYAxis',true,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('col',[0.6 0.6 0.6],@isvector);
			p.addParameter('shouldPlotPointEstimate',false,@islogical);
			p.addParameter('FaceAlpha',0.2,@isscalar);
			p.addParameter('patchProperties',{'FaceAlpha',0.8},@iscell);
			p.addParameter('plotHDI',true,@islogical);
			p.addParameter('axisSquare',true,@islogical);
			
			p.parse(varargin{:});
			
			obj.plot_options = p.Results;
		end
	end
	
	
	
	
end
