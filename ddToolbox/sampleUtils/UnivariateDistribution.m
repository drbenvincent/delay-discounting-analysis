classdef UnivariateDistribution < handle

	properties (Access = public)
		posteriorSamples, priorSamples
		xLabel,
		XRANGE,
		xi,
		density
		mean, median, mode
		pointEstimateType
		shouldPlot
		priorCol
		posteriorCol
		killYAxis
		plotHDI
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
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('killYAxis',false,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('posteriorCol',[0.2 0.2 0.2],@isvector);
			p.addParameter('pointEstimateType','mean', @(x)any(strcmp(x,{'mean','median','mode'})));
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
			%obj.calculateDensityAndPointEstimates(XXXXXXXX)

			if p.Results.shouldPlot
				obj.plot()
			end

		end

		function calculateDensityAndPointEstimates(obj, method, XN, YN)
			%% Compute the univariate density
			switch method

			% 	case{'bensSlowCode'}
			% 		% a 2D histogram method
			% 		xvec = linspace(obj.XRANGE(1), obj.XRANGE(2), obj.XN);
			% 		yvec = linspace(obj.YRANGE(1), obj.YRANGE(2), obj.YN);
			% 		[obj.density,bx,by, modex, modey] = myHist2D(obj.posteriorSamples, obj.priorSamples, xvec, yvec);
			% 		obj.mode = [modex modey];
			%
			% 	case{'hist2d'}
			% 		% a 2D histogram method
			% 		[obj.density, bx, by] = hist2d([obj.posteriorSamples obj.priorSamples], obj.XN, obj.YN, obj.XRANGE, obj.YRANGE);
			% 		% imagesc(bx, by, density)
			%
			% 		% Find the mode
			% 		[i,j]	= argmax2(obj.density);
			% 		modex	= bx(i);
			% 		modey	= by(j);
			% 		obj.mode = [modex modey];
			%
			% 	case{'kde2d'}
			% 		MIN_XY = [obj.XRANGE(1) obj.YRANGE(1)];
			% 		MAX_XY = [obj.XRANGE(2) obj.YRANGE(2)];
			% 		[~,obj.density,X,Y]=kde2d([obj.posteriorSamples obj.priorSamples],288*2,MIN_XY,MAX_XY);
			%
			% 		bx = X(1,:);
			% 		by = Y(:,1);
			%
			% 		% Find the mode
			% 		[i,j]	= argmax2(obj.density');
			% 		modex	= bx(i);
			% 		modey	= by(j);
			% 		obj.mode = [modex modey];
			%
			% % 		imagesc(X(1,:),Y(:,1),obj.density)
			% % 		axis xy
			% 	case{'ksdensity'} % matlab built in function
			% 		bx = linspace(obj.XRANGE(1), obj.XRANGE(2), obj.XN);
			% 		by = linspace(obj.YRANGE(1), obj.YRANGE(2), obj.YN);
			% 		[X,Y] = meshgrid(bx, by);
			% 		%xi = [X(:) Y(:)];
			%
			% 		[f,~] = ksdensity([obj.posteriorSamples obj.priorSamples], [X(:) Y(:)]); % <----- SLOW
			% 		obj.density = reshape(f,size(X));
			%
			% 		% Find the mode
			% 		[i,j]	= argmax2(obj.density);
			% 		modex	= bx(j);
			% 		modey	= by(i);
			% 		obj.mode = [modex modey];

			end

			obj.xi = bx(:);

		end

		function plot(obj)

			hPost=histogram(obj.posteriorSamples(:),...
				'Normalization','pdf',...
				'EdgeColor','none',...
				'FaceColor',obj.posteriorCol);
			axis tight
			a=axis;

			hold on

			hPrior=histogram(obj.priorSamples(:),...
				'Normalization','pdf',...
				'EdgeColor','none',...
				'FaceColor',obj.priorCol);


			if ~isempty(obj.posteriorSamples)
				axis(a)
			else
				axis tight
			end

			box off
			set(gca,'TickDir','out')

			if obj.killYAxis
				removeYaxis()
			end
			axis square

			xlabel(obj.xLabel, 'interpreter', 'latex')

			if obj.plotHDI
				showHDI(obj.posteriorSamples)
			end

			set(gca,'Layer','top');

			% switch obj.pointEstimateType
			% 	case{'mean'}
			% 		plot(obj.mean(1), obj.mean(2), 'ro')
			% 	case{'median'}
			% 		plot(obj.median(1), obj.median(2), 'ro')
			% 	case{'mode'}
			% 		plot(obj.mode(1), obj.mode(2), 'ro')
			% end

		end

  end

end
