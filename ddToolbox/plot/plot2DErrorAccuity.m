function [structName] = plot2DErrorAccuity(epsilon, alpha, epsilon_mean, alpha_mean)

epsilon=epsilon(:);
alpha=alpha(:);

[structName] = calcBivariateSummaryStats(epsilon,alpha, 500, 500, 'kde2d');

% plot
imagesc(structName.xi*100, structName.yi, structName.density);
axis xy
colormap(gca, flipud(gray));
xlabel('percent errors, $\epsilon$','Interpreter','latex')
ylabel('comparison accuity, $\alpha$','Interpreter','latex')
axis square
hold on
box off
% indicate posterior mean
plot(epsilon_mean*100, alpha_mean, 'ro')

% TODO: fix this commented code *******************************************
% % plot MODE and 95% CI text
% % TODO: grab this from analysis already done, no need to recompute
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(epsilon*100, 'positive');
% lr_text = sprintf('$$ \\epsilon = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
% 
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(alpha, 'positive');
% alpha_text = sprintf('$$ \\alpha = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
% 
% str(1)={lr_text};
% str(2)={alpha_text};
% addTextToFigure('TR',str, 12, 'latex');
return
