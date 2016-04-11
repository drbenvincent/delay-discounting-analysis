classdef BivariateDistribution < handle

	properties (Access = public)
		xSamples, ySamples
		xLabel, yLabel
		XRANGE, YRANGE
		xi, yi
		density
		mean, median, mode
		pointEstimateType
		shouldPlot
	end

	properties (GetAccess = public, SetAccess = protected)

	end

  methods (Access = public)

		function obj = BivariateDistribution(xSamples, ySamples, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('xSamples',@isvector);
			p.addRequired('ySamples',@isvector);
			p.addParameter('xLabel','',@isstr);
			p.addParameter('yLabel','',@isstr);
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('pointEstimateType','mean',@isstr); % TODO improve validation here
			p.parse(xSamples, ySamples, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			obj.XRANGE = [min(xSamples) max(xSamples)];
			obj.YRANGE = [min(ySamples) max(ySamples)];

			% Calculate stats upon construction
			obj.mean = [mean(obj.xSamples) mean(obj.ySamples)];
			obj.median = [median(obj.xSamples) median(obj.ySamples)];
			obj.calculateDensityAndPointEstimates('kde2d',500,500)

			if p.Results.shouldPlot
				obj.plot()
			end

		end

		function calculateDensityAndPointEstimates(obj, method, XN, YN)
			%% Compute the bivariate density
			switch method

				case{'bensSlowCode'}
					% a 2D histogram method
					xvec = linspace(obj.XRANGE(1), obj.XRANGE(2), obj.XN);
					yvec = linspace(obj.YRANGE(1), obj.YRANGE(2), obj.YN);
					[obj.density,bx,by, modex, modey] = myHist2D(obj.xSamples, obj.ySamples, xvec, yvec);
					obj.mode = [modex modey];

				case{'hist2d'}
					% a 2D histogram method
					[obj.density, bx, by] = hist2d([obj.xSamples obj.ySamples], obj.XN, obj.YN, obj.XRANGE, obj.YRANGE);
					% imagesc(bx, by, density)

					% Find the mode
					[i,j]	= argmax2(obj.density);
					modex	= bx(i);
					modey	= by(j);
					obj.mode = [modex modey];

				case{'kde2d'}
					MIN_XY = [obj.XRANGE(1) obj.YRANGE(1)];
					MAX_XY = [obj.XRANGE(2) obj.YRANGE(2)];
					[~,obj.density,X,Y]=kde2d([obj.xSamples obj.ySamples],288*2,MIN_XY,MAX_XY);

					bx = X(1,:);
					by = Y(:,1);

					% Find the mode
					[i,j]	= argmax2(obj.density');
					modex	= bx(i);
					modey	= by(j);
					obj.mode = [modex modey];

			% 		imagesc(X(1,:),Y(:,1),obj.density)
			% 		axis xy
				case{'ksdensity'} % matlab built in function
					bx = linspace(obj.XRANGE(1), obj.XRANGE(2), obj.XN);
					by = linspace(obj.YRANGE(1), obj.YRANGE(2), obj.YN);
					[X,Y] = meshgrid(bx, by);
					%xi = [X(:) Y(:)];

					[f,~] = ksdensity([obj.xSamples obj.ySamples], [X(:) Y(:)]); % <----- SLOW
					obj.density = reshape(f,size(X));

					% Find the mode
					[i,j]	= argmax2(obj.density);
					modex	= bx(j);
					modey	= by(i);
					obj.mode = [modex modey];

			end

			obj.xi = bx(:);
			obj.yi = by(:);

		end

		function plot(obj)
			imagesc(obj.xi, obj.yi, obj.density);
			axis xy
			colormap(gca, flipud(gray));
			xlabel(obj.xLabel,'Interpreter','latex')
			ylabel(obj.yLabel,'Interpreter','latex')
			axis square
			hold on
			box off

			% alternative plot style...
			% h = histogram2(obj.POSTERIOR(:,col), obj.POSTERIOR(:,row),...
			% 		'DisplayStyle','tile',...
			% 		'ShowEmptyBins','on',...
			% 		'EdgeColor','none');
			% 	axis xy
			% 	axis square
			% 	axis tight
			% 	colormap(flipud(gray))


% 			% TODO see if this works, rather than the code below
% 			plot(...
% 				obj.(obj.pointEstimateType))(1), obj.(obj.pointEstimateType))(2), 'ro')

			switch obj.pointEstimateType
				case{'mean'}
					h=plot(obj.mean(1), obj.mean(2), 'ro')
				case{'median'}
					h=plot(obj.median(1), obj.median(2), 'ro')
				case{'mode'}
					h=plot(obj.mode(1), obj.mode(2), 'ro')
			end
			h.MarkerFaceColor = [1 1 1];
			h.MarkerEdgeColor = [0 0 0];

		end

  end

end
