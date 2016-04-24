classdef UnivariateDistribution < handle

	properties (Access = public)
		xLabel,
		mean, median, mode
		pointEstimateType
		priorCol
		posteriorCol
		plotHDI
		plotStyle
	end

	properties (Access = private)
		posteriorSamples, priorSamples
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
			p.addRequired('posteriorSamples',@isvector);
			p.addParameter('priorSamples',[],@isvector);
			p.addParameter('xLabel','',@isstr);
			p.addParameter('plotStyle','kde',@(x)any(strcmp(x,{'hist','kde'})))
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('killYAxis',true,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('posteriorCol',[0.6 0.6 0.6],@isvector);
			p.addParameter('pointEstimateType','mode', @(x)any(strcmp(x,{'mean','median','mode'})));
			p.addParameter('plotHDI',true,@islogical);
			p.parse(posteriorSamples, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			% obj.XRANGE = [min(posteriorSamples) max(posteriorSamples)];
			% obj.YRANGE = [min(priorSamples) max(priorSamples)];

			% Calculate stats upon construction
			obj.mean = mean(obj.posteriorSamples);
			obj.median = median(obj.posteriorSamples);
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
			[obj.density, obj.xi] = ksdensity(obj.posteriorSamples);
			[~,ind] = max(obj.density);
			obj.mode = obj.xi( ind );
		end


		function plotHist(obj)
			hPost=histogram(obj.posteriorSamples(:),...
				'Normalization','pdf',...
				'EdgeColor','none',...
				'FaceColor',obj.posteriorCol,...
				'FaceAlpha',1);
			axis tight
			a=axis;

			if ~isempty(obj.posteriorSamples)
				axis(a)
			else
				axis tight
			end

		end


		function plotDensity(obj)
			h = fill(obj.xi,...
				obj.density,...
				obj.posteriorCol,...
				'EdgeColor','none');
		end


		function plotPointEstimate(obj)
			a = axis;
			h = line( [obj.(obj.pointEstimateType) obj.(obj.pointEstimateType)],...
				[a(3) a(4)]);
			h.Color = 'k';
		end


		function formatAxes(obj)

			if obj.killYAxis
				mcmc.removeYaxis()
			end

			if obj.plotHDI
				mcmc.showHDI(obj.posteriorSamples)
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
