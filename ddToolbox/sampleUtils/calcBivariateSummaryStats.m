function [outputStruc] = calcBivariateSummaryStats(x,y, XN, YN)
% This function takes in two vectors corresponding to MCMC samples of two
% parameters. It will then compute the bivariate density and use that that
% to estimate the bivariate posterior mode.

% ensure x and y are vectors
x=x(:);
y=y(:);

XRANGE = [min(x) max(x)];
YRANGE = [min(y) max(y)];

%% Compute the bivariate density
%method = 'bensSlowCode';
%method = 'hist2d';
method = 'ksdensity';

switch method
	
	case{'bensSlowCode'}
		% a 2D histogram method
		xvec = linspace(XRANGE(1), XRANGE(2), XN);
		yvec = linspace(YRANGE(1), YRANGE(2), YN);
		[density,bx,by, modex, modey] = myHist2D(lr , sigma, xvec, yvec);
		
	case{'hist2d'}
		% a 2D histogram method
		[density, bx, by] = hist2d([x y], XN, YN, XRANGE, YRANGE);
		
		% Find the mode
		[i,j]	= argmax2(density);
		modex	= bx(i);
		modey	= by(j);
		
	case{'kde2d'}
		MIN_XY = [XRANGE(1) YRANGE(1)];
		MAX_XY = [XRANGE(2) YRANGE(2)];
		[~,density,X,Y]=kde2d([x y],288*2,MIN_XY,MAX_XY);

		bx = X(1,:);
		by = Y(:,1);
		
		% Find the mode
		[i,j]	= argmax2(density');
		modex	= bx(i);
		modey	= by(j);
		
% 		imagesc(X(1,:),Y(:,1),density)
% 		axis xy
	case{'ksdensity'} % matlab built in function
		bx = linspace(XRANGE(1), XRANGE(2), XN);
		by = linspace(YRANGE(1), YRANGE(2), YN);
		[X,Y] = meshgrid(bx, by);
		xi = [X(:) Y(:)];
		
		[f,xi] = ksdensity([x y], xi); % <----- SLOW
		density = reshape(f,size(X));
		
		% Find the mode
		[i,j]	= argmax2(density);
		modex	= bx(j);
		modey	= by(i);
		
end

outputStruc.modex = modex;
outputStruc.modey = modey;
outputStruc.density = density ./ sum(density(:));
outputStruc.xi = bx(:);
outputStruc.yi = by(:);

% entropy = log2(density(:)) .* density(:);
% entropy(isnan(entropy)) = 0;
% outputStruc.entropy = - sum( entropy ); % in units of bits
return