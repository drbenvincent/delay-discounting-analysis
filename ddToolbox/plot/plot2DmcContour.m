function [structName] = plot2DmcContour(m, c)

m=m(:);
c=c(:);

mlim = [min(m) max(m)];
clim = [min(c) max(c)];

[structName] = calcBivariateSummaryStats(m,c, 500, 500, mlim, clim);
% normalise to a probability mass function
structName.density = structName.density./sum(structName.density(:));

%% plot
%imagesc(structName.xi, structName.yi, structName.density);
val = max(structName.density(:))/2;% <---- MAKE THIS MORE MEANINGFUL
[M, C] = meshgrid(structName.xi, structName.yi);
%contour(M,C,structName.density, [val val])
[XY,h] = contour(M,C,structName.density, [val val]);
%h.LineStyle = 'none';


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
return
