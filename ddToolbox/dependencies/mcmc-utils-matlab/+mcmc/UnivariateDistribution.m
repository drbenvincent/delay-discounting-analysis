classdef UnivariateDistribution < handle

	properties (Access = public)
		xLabel,
		mean, median, mode
		pointEstimateType
		shouldPlotPointEstimate
		col
		plotHDI
		plotStyle
		N
		FaceAlpha
	end

	properties (Access = private)
		samples
		priorSamples, priorCol
		XRANGE
		xi
		density
		shouldPlot
		killYAxis
	end

	properties (GetAccess = public, SetAccess = protected)

	end

	methods (Access = public)

		function obj = UnivariateDistribution(posteriorSamples, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('samples',@ismatrix);
			p.addParameter('priorSamples',[],@isvector);
			p.addParameter('xLabel','',@isstr);
			p.addParameter('plotStyle','kde',@(x)any(strcmp(x,{'hist','kde'})))
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('killYAxis',true,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('col',[0.6 0.6 0.6],@isvector);
			p.addParameter('pointEstimateType','mode', @(x)any(strcmp(x,{'mean','median','mode'})));
			p.addParameter('shouldPlotPointEstimate',false,@islogical);
			p.addParameter('FaceAlpha',0.2,@isscalar);
			p.addParameter('plotHDI',true,@islogical);
			p.parse(posteriorSamples, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			obj.N = size(obj.samples,2);
			% obj.XRANGE = [min(posteriorSamples) max(posteriorSamples)];
			% obj.YRANGE = [min(priorSamples) max(priorSamples)];

			% Calculate stats upon construction
			obj.mean = mean(obj.samples);
			obj.median = median(obj.samples);
			obj.calculateDensityAndPointEstimates();

			if p.Results.shouldPlot
				obj.plot();
			end

		end

		function plot(obj)
			switch obj.plotStyle
					case{'hist'}
						obj.plotHist();
					case{'kde'}
						obj.plotDensity();
			end
			obj.formatAxes();
			obj.plotPointEstimate();
		end

		function calculateDensityAndPointEstimates(obj)
			obj.xi = linspace( min(obj.samples(:)), max(obj.samples(:)), 500);
			for n=1:obj.N
				[obj.density(:,n), ~] = ksdensity(obj.samples(:,n), obj.xi);
				[~,ind] = max(obj.density(:,n));
				obj.mode(n) = obj.xi( ind );
			end
		end


		function plotHist(obj)
			hold on
			for n=1:obj.N
				hPost(n)=histogram(obj.samples(:,n),...
					'Normalization','pdf',...
					'EdgeColor','none',...
					'FaceColor',obj.col,...
					'FaceAlpha',obj.FaceAlpha);
			end
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
			end
		end


		function plotPointEstimate(obj)
			if ~obj.shouldPlotPointEstimate, return, end
			a = axis;
			for n=1:obj.N
				h = line( [obj.(obj.pointEstimateType)(n) obj.(obj.pointEstimateType)(n)],...
					[a(3) a(4)]);
				h.Color = 'k';
			end
		end


		function formatAxes(obj)

			if obj.killYAxis
				mcmc.removeYaxis()
			end

			if obj.plotHDI
				for n=1:obj.N
					mcmc.showHDI(obj.samples(:,n))
				end
			end

			box off
			axis tight
			axis square
			set(gca,'TickDir','out')
			set(gca,'Layer','top');
			xlabel(obj.xLabel, 'interpreter', 'latex')
		end

	end

end
