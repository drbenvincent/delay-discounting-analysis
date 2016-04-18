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
			p.addParameter('pointEstimateType','mean', @(x)any(strcmp(x,{'mean','median','mode'})));
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
					Xedges = linspace(min(obj.XRANGE),max(obj.XRANGE), obj.XN);
					Yedges = linspace(min(obj.YRANGE),max(obj.YRANGE), obj.YN);
					%[X,Y] = meshgrid(Xedges,Yedges);
					[obj.density,~,~,binx,biny] = histcounts2(x,y,[100 100],...
						'Normalization','count');

					% Find the mode
					[i,j]	= argmax2(obj.density);
					modex	= bx(i);
					modey	= by(j);
					obj.mode = [modex modey];
					
% 					% a 2D histogram method
% 					[obj.density, bx, by] = hist2d([obj.xSamples obj.ySamples], obj.XN, obj.YN, obj.XRANGE, obj.YRANGE);
% 					% imagesc(bx, by, density)
% 
% 					% Find the mode
% 					[i,j]	= argmax2(obj.density);
% 					modex	= bx(i);
% 					modey	= by(j);
% 					obj.mode = [modex modey];

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
					h=plot(obj.mean(1), obj.mean(2), 'ro');
				case{'median'}
					h=plot(obj.median(1), obj.median(2), 'ro');
				case{'mode'}
					h=plot(obj.mode(1), obj.mode(2), 'ro');
			end
			h.MarkerFaceColor = [1 1 1];
			h.MarkerEdgeColor = [0 0 0];

			set(gca,'Layer','top');
		end
		
		
		function plotContour(obj, probabilityMassAmount, plotOpts)
			assert(probabilityMassAmount>0 && probabilityMassAmount<1,...
				'probabilityMassAmount must be a proportion, not a percentage')
			
			%% Obtain threshold
% 			totalCount = sum(obj.density(:));
% 			massAboveThreshold=inf;
% 			threshold=0;
% 			while massAboveThreshold>probabilityMassAmount
% 				massAboveThreshold = sum(obj.density( obj.density(:)>threshold )) / totalCount;
% 				threshold=threshold+1;
% 			end
			
			warning('SLOW-ASS ALGORITHM!')
			obj.density = obj.density ./ sum(obj.density(:));
			list = sort(obj.density(:));
			for i=1:numel(list)
				threshold = list(end-i);
				massAboveThreshold = sum(obj.density( obj.density(:)>threshold ));
				if massAboveThreshold>probabilityMassAmount
					break
				end
			end
			threshold = list(end-i);
			display(threshold)
			
			
			%% Plot
			contourmatrix = contourc(obj.xi, obj.yi, obj.density, [threshold, threshold]);
			
			% Code below solves a plotting issue I was having, solved by a contributor
			% from Stackoverflow.
			% http://stackoverflow.com/questions/36220201/multiple-matlab-contour-plots-with-one-level
			parsed = false ;
			iShape = 1 ;
			while ~parsed
				%// get coordinates for each isolevel profile
				%level   = contourmatrix(1,1) ; %// current isolevel
				nPoints = contourmatrix(2,1) ; %// number of coordinate points for this shape
				
				idx = 2:nPoints+1 ; %// prepare the column indices of this shape coordinates
				xp = contourmatrix(1,idx) ;     %// retrieve shape x-values
				yp = contourmatrix(2,idx) ;     %// retrieve shape y-values
				hp(iShape) = patch(xp,yp,'k') ; %// generate path object and save handle for future shape control.
				
				if size(contourmatrix,2) > (nPoints+1)
					%// There is another shape to draw
					contourmatrix(:,1:nPoints+1) = [] ; %// remove processed points from the contour matrix
					iShape = iShape+1 ;     %// increment shape counter
				else
					%// we are done => exit while loop
					parsed  = true ;
				end
			end
			
			set(hp, plotOpts);

			axis xy
			grid on
			colormap(gca, flipud(gray));
			xlabel('slope, $m$','Interpreter','latex')
			ylabel('intercept, $c$','Interpreter','latex')
			axis square
			hold on
			box off

		end

  end

end
