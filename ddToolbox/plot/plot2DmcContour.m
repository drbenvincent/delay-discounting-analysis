function [bi] = plot2DmcContour(m, c, probabilityMass, plotOpts)


%% Create a bivariate pmf
[bi] = calcBivariateSummaryStats(m, c, 100, 100, 'hist2d');
%imagesc(bi.xi, bi.yi, bi.density)
%plot(bi.modex, bi.modey, 'ko')
%axis xy

%% Find density value containing `probabilityMass` of the pmf
normalisedVec = bi.density(:) ./ sum(bi.density(:));
options	=optimset('MaxIter',10000, 'Display','off');

errFunc = @(val,normalisedVec) abs( sum( normalisedVec(normalisedVec>val) ) - probabilityMass );
valvec = linspace(0,max(normalisedVec),1000);
for n=1:numel(valvec)
	err(n) = errFunc( valvec(n), normalisedVec);
end
%plot(valvec, err)
[a b] = min(err);
val = valvec(b);

% %[val, err, exitflag] = fminbnd(@errorfunction,0, max(normalisedVec), options, bi.density);
% [val, err, exitflag] = fminbnd(@errorfunction,0, max(normalisedVec), options, normalisedVec);
% %[val, err, exitflag] = fminbnd( errFunc, 0, max(normalisedVec), options, normalisedVec);
% err
% assert(exitflag==1)
% 
% 	function err = errorfunction(val, normalisedVec)
% 		err = abs( sum( normalisedVec(normalisedVec>val) ) - probabilityMass );
% 	end


%% Calculate contour
contourmatrix = contourc(bi.xi, bi.yi, bi.density, [val, val]);

%% Draw
% figure
% subplot(1,2,1)

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
axis([-1.5 0.5 -20 5])


% subplot(1,2,2)
% imagesc(bi.xi, bi.yi, bi.density)
% hold on
% plot(bi.modex, bi.modey, 'ko')
% axis xy
% axis([-1.5 0.5 -20 5])



% apply plotOptions
set(hp, plotOpts);

% hold on
% plot(bi.modex, bi.modey, 'ko')


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


drawnow
end
