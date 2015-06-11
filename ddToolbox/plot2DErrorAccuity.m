function [structName] = plot2DErrorAccuity(epsilon, alpha, xrange, yrange)



epsilon=epsilon(:);
alpha=alpha(:);

[structName] = bivariateAnalysis(epsilon,alpha, 500, 500, xrange, yrange);



% %% Find the posterior mode of the bivariate density of lr and sigma
% % methods available: 'bensSlowCode' | 'hist2d'
% method = 'hist2d';
% 
% switch method
% 	case{'bensSlowCode'}
% 		% lrvec=linspace(0,0.5,100);
% 		% sigmavec=linspace(0,max(sigma),100);
% 		% [density,bx,by, modex, modey]=my_2d_hist(lr , sigma, lrvec, sigmavec);
% 	case{'hist2d'}
% 		% use a faster one from Mathworks File Exchange ---------------------------
% 		[density, bx, by] = hist2d([lr sigma], 100, 100, [0 0.5], [0 max(sigma)]);
% 		
% 		% Calculate mode: simple method directly from histogram
% 		[i,j]	= argmax2(density);
% 		modex	= bx(i);
% 		modey	= by(j);
% end

%% plot
% plot
imagesc(structName.xi*100, structName.yi, structName.density);
axis xy
colormap(gca, flipud(gray));
% -------------------------------------------------------------------------
xlabel('percent errors, $\epsilon$','Interpreter','latex')
ylabel('comparison accuity, $\alpha$','Interpreter','latex')
axis square
hold on
box off
plot(structName.modex*100, structName.modey, 'ro')



% plot MODE and 95% CI text
display('grab this from analysis already done, no need to recompute')
[estimated_mode, ~, ~, ci95] = sampleStats(epsilon*100, 'positive');
lr_text = sprintf('$$ \\epsilon = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));

[estimated_mode, ~, ~, ci95] = sampleStats(alpha, 'positive');
alpha_text = sprintf('$$ \\alpha = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));

str(1)={lr_text};
str(2)={alpha_text};
add_text_to_figure('TR',str, 12, 'latex')

return