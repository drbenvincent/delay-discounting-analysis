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
		N
	end
	
	properties (GetAccess = public, SetAccess = protected)
		
	end
	
	methods (Access = public)
		
		function obj = BivariateDistribution(xSamples, ySamples, varargin)			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('xSamples',@ismatrix);
			p.addRequired('ySamples',@ismatrix);
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
			
			assert(size(xSamples,2)==size(ySamples,2));
			obj.N = size(xSamples,2);
			if obj.N>1 && ~strcmp(obj.plotStyle,'contour')
				obj.plotStyle = 'contour';
				warning('plotStyle changed to ''contour'' when >1 set of samples')
			end
			
			obj.XRANGE = [min(xSamples(:)) max(xSamples(:))];
			obj.YRANGE = [min(ySamples(:)) max(ySamples(:))];
			
			% Calculate stats upon construction
			obj.mean = [mean(obj.xSamples); mean(obj.ySamples)];
			obj.median = [median(obj.xSamples); median(obj.ySamples)];
			obj.calculateDensityAndPointEstimates('kde2d',500,500)
			
			if p.Results.shouldPlot
				obj.plot()
			end
			
		end
		
		function calculateDensityAndPointEstimates(obj, method, XN, YN)
			%% Compute the bivariate density
			switch method	
				case{'kde2d'}
					for n=1:obj.N
						MIN_XY = [obj.XRANGE(1) obj.YRANGE(1)];
						MAX_XY = [obj.XRANGE(2) obj.YRANGE(2)];
						
						[~,obj.density(:,:,n),X,Y]=mcmc.kde2d.kde2d([obj.xSamples(:,n) obj.ySamples(:,n)],288*2,MIN_XY,MAX_XY);
						
						bx = X(1,:);
						by = Y(:,1);
						
						% Find the mode
						[i,j]	= mcmc.argmax2(obj.density(:,:,n)');
						modex	= bx(i);
						modey	= by(j);
						obj.mode(:,n) = [modex modey];
					end
					
				case{'ksdensity'} % built in matlab function
					for n=1:obj.N
						bx = linspace(obj.XRANGE(1), obj.XRANGE(2), XN);
						by = linspace(obj.YRANGE(1), obj.YRANGE(2), YN);
						[X,Y] = meshgrid(bx, by);
						%xi = [X(:) Y(:)];
						
						[f,~] = ksdensity([obj.xSamples(:,n) obj.ySamples(:,n)], [X(:) Y(:)]); % <----- SLOW
						obj.density(:,n) = reshape(f,size(X));
						
						% Find the mode
						[i,j]	= argmax2(obj.density(:,n));
						modex	= bx(j);
						modey	= by(i);
						obj.mode(:,n) = [modex modey];
					end
					
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
			if obj.N>1
				error('This plot style is not supported for multiple distributions')
			end
			imagesc(obj.xi, obj.yi, obj.density);
		end
		
		
		function plotHist(obj)
			if obj.N>1
				error('This plot style is not supported for multiple distributions')
			end
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
			for n=1:obj.N
				%% Obtain threshold level containing desired probability mass
				% normalise
				obj.density(:,:,n) = obj.density(:,:,n) ./ sum( mcmc.vec(obj.density(:,:,n)));
				% make a vector copy *also normalised*
				list = mcmc.vec( obj.density(:,:,n) ./ sum(mcmc.vec(obj.density(:,:,n))) );
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
				contourmatrix = contourc(obj.xi, obj.yi, obj.density(:,:,n), [threshold, threshold]);
				
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
		end
		
		function plotPointEstimate(obj)
			for n=1:obj.N
				h = plot( obj.(obj.pointEstimateType)(1,n),...
					obj.(obj.pointEstimateType)(2,n), 'ro');
				h.MarkerFaceColor = [1 1 1];
				h.MarkerEdgeColor = [0 0 0];
			end
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
