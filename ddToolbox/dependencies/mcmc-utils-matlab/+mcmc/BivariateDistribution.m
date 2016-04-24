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
		plotStyle
		gridOn
		probMass
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
			p.addParameter('probMass',0.95,@isscalar); % for contour plot
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('gridOn',true,@islogical);
			p.addParameter('plotStyle','kde',@(x)any(strcmp(x,{'hist','kde','contour'})))
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
				case{'kde2d'}
					MIN_XY = [obj.XRANGE(1) obj.YRANGE(1)];
					MAX_XY = [obj.XRANGE(2) obj.YRANGE(2)];

					[~,obj.density,X,Y]=mcmc.kde2d.kde2d([obj.xSamples obj.ySamples],288*2,MIN_XY,MAX_XY);
					
					bx = X(1,:);
					by = Y(:,1);
					
					% Find the mode
					[i,j]	= mcmc.argmax2(obj.density');
					modex	= bx(i);
					modey	= by(j);
					obj.mode = [modex modey];
					
				case{'ksdensity'} % built in matlab function
					bx = linspace(obj.XRANGE(1), obj.XRANGE(2), XN);
					by = linspace(obj.YRANGE(1), obj.YRANGE(2), YN);
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
			switch obj.plotStyle
				case{'hist'}
					obj.plotHist();
				case{'kde'}
					obj.plotDensity();
				case{'contour'}
					obj.plotContour();
			end
			obj.formatAxes();
			obj.plotPointEstimate();
			
		end
		
		
		function plotDensity(obj)
			imagesc(obj.xi, obj.yi, obj.density);
		end
		
		
		function plotHist(obj)
			h = histogram2(obj.xSamples, obj.ySamples,...
				'DisplayStyle','tile',...
				'ShowEmptyBins','on',...
				'EdgeColor','none');
			axis xy
			colormap(flipud(gray))
		end
		
		function plotContour(obj, varargin)
			
			
			assert(obj.probMass>0 && obj.probMass<1,...
				'probMass must be a proportion, not a percentage')
			
			%% Obtain threshold level containing desired probability mass
			% normalise
			obj.density = obj.density./sum(obj.density(:));
			% make a vector copy *also normalised*
			list = obj.density(:)./sum(obj.density(:));
			% find threshold
			opts = optimset;
			opts.Display=true;
			opts.TolX =10^-6;
			[threshold,FVAL,EXITFLAG,OUTPUT] = fminsearch(@(x) (obj.probMass - sum(list( list>x)))^2,...
				max(list)/2,...
				opts);
			
			% % TESTING CODE. Works
			% err = @(x,pm) (pm - sum(list( list>x)))^2;
			% pmass=[];
			% for x = linspace(0,max(list),1000)
			% 	pmass = [pmass err(x,obj.probMass)];
			% end
			% plot(linspace(0,max(list),1000), pmass)
			
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
			
			% apply plot options to patch
			patchOptions={'FaceAlpha',0.2,...
				'LineStyle','none'};
			set(hp, patchOptions{:});

		end
		
		function plotPointEstimate(obj)
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
		end
		
		
		function formatAxes(obj)
			if obj.gridOn
				grid on
			else
				grid off
			end
			axis xy
			colormap(gca, flipud(gray));
			xlabel(obj.xLabel,'Interpreter','latex')
			ylabel(obj.yLabel,'Interpreter','latex')
			axis square
			hold on
			box off
			set(gca,'Layer','top');
		end
		
		
	end
	
end
