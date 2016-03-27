function [bi] = plot2DmcContour(m, c, probabilityMass, plotOpts)

m=m(:);
c=c(:);

mlim = [min(m) max(m)];
clim = [min(c) max(c)];

[bi] = calcBivariateSummaryStats(m,c, 400, 400, mlim, clim);


%% The aim is to draw a contour which contains 50% of the probability mass.
normalisedVec = bi.density(:);
options	=optimset('MaxIter',1000, 'Display','off');
[val, err, exitflag] = fminbnd(@errorfunction,0, max(normalisedVec), options, bi.density);

	function err = errorfunction(val, FnormalisedVec)
		pm = sum( FnormalisedVec(FnormalisedVec>val) );
		err = abs( pm - probabilityMass );
	end


%%
contourmatrix = contourc(bi.xi, bi.yi, bi.density, [val, val]);

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

    if size(c,2) > (nPoints+1)
        %// There is another shape to draw
        contourmatrix(:,1:nPoints+1) = [] ; %// remove processed points from the contour matrix
        iShape = iShape+1 ;     %// increment shape counter
    else
       %// we are done => exit while loop
       parsed  = true ;
    end
end
grid on

% apply plotOptions
set(hp, plotOpts);

axis xy
colormap(gca, flipud(gray));
xlabel('slope, $m$','Interpreter','latex')
ylabel('intercept, $c$','Interpreter','latex')
axis square
hold on
box off
% indicate posterior mean
% plot(m_mean, c_mean, 'ro')
%vline(0, 'Color','k', 'LineWidth',0.5)

% TODO: fix this commented code *******************************************
% %% Add text to figure
% % add text to say P(m<0)
% probMlessThanZero = sum(m<0)./numel(m);
% str(1)={ sprintf('$$ P(m<0)=%2.2f $$',probMlessThanZero) };
% % TODO: grab this from analysis already done, no need to recompute
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(m, []);
% Mtext = sprintf('$$ m = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
% str(2)={Mtext};
% 
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(c, []);
% Ctext = sprintf('$$ c = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
% str(3)={Ctext};
% 
% h = addTextToFigure('TR',str, 12, 'latex');
% % set background colour as white, but with some alpha
% h.BackgroundColor=[1 1 1 0.7];

drawnow
end
