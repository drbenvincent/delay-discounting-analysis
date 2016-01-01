function [structName] = plot2Dmc(m, c)

% TODO: plot2Dmc and plot2DErrorAccuity are basically doing the same things

m=m(:);
c=c(:);

mlim = [min(m) max(m)];
clim = [min(c) max(c)];

[structName] = calcBivariateSummaryStats(m,c, 500, 500, mlim, clim);

%fprintf('\nENTROPY OF (M,C): %3.2f bits\n', structName.entropy)

%% plot
imagesc(structName.xi, structName.yi, structName.density);
axis xy
colormap(gca, flipud(gray));
xlabel('slope, $m$','Interpreter','latex')
ylabel('intercept, $c$','Interpreter','latex')
axis square
hold on
box off
% indicate posterior mode
plot(structName.modex, structName.modey, 'ro')

vline(0, 'Color','k', 'LineWidth',0.5)

% add text to say P(m<0)
probMlessThanZero = sum(m<0)./numel(m);




%% Add text to figure
str(1)={ sprintf('$$ P(m<0)=%2.2f $$',probMlessThanZero) };


% TODO: grab this from analysis already done, no need to recompute
[estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(m, []);
Mtext = sprintf('$$ m = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
str(2)={Mtext};

[estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(c, []);
Ctext = sprintf('$$ c = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
str(3)={Ctext};

h = addTextToFigure('TR',str, 12, 'latex');
% set background colour as white, but with some alpha
h.BackgroundColor=[1 1 1 0.7];


return
