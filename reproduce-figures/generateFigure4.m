function generateFigure4

%close all

opts.maxlogB	= 10000;
opts.maxD		= 365;

figure(1), clf

% %% Parameter space
% subplot(1,2,1)
% title('a.')
% hold on
% xlabel('m')
% ylabel('c')
% axis square
% axis([-4 1 -5 5])

%% EXAMPLE 1
m=-0.5; c= -1;
subplot(2,2,1)
internalPlotMagEffect(m,c)
title('a.')

add_text_to_figure('TR','$\log(k) = -0.5\log($reward$)-1$', 12, 'latex')

subplot(2,2,2)
calculateDiscountSurface(m,c, opts );
title('b.')
%forceNonExponentialTick
% subplot(1,2,1)
% plot(m,c,'.r','MarkerSize',6^2)

%% EXAMPLE 2 - magnitude effect
m=-1.5; c= +1;
subplot(2,2,3)
internalPlotMagEffect(m,c)
title('c.')

add_text_to_figure('TR','$\log(k) = -1.5\log($reward$)+1$', 12, 'latex')

subplot(2,2,4)
calculateDiscountSurface(m,c, opts );
title('d.')
%forceNonExponentialTick

% subplot(1,2,1)
% plot(m,c,'.r','MarkerSize',6^2)

%%
latex_fig(16, 6, 6)
subplot(2,2,2), set(gca,'xticklabel',num2str(get(gca,'xtick')'))
subplot(2,2,4), set(gca,'xticklabel',num2str(get(gca,'xtick')'))
% %% Export
% figName = 'ExplanatoryFigure-MagnitudeEffect';
% set(gcf,'Color','w')
% % EXPORTING ---------------------
% myExport([], figName, [])
% % -------------------------------


return


function internalPlotMagEffect(m,c)

fh = @(x,params) exp( m * log(x) + c);
x=logspace(0,4,50);
y = fh(x);
plot(x,y)

box off

set(gca,'XScale','log')
set(gca,'YScale','log')

ylim([10^-4 10^1])

set(gca,'XTick',logspace(1,6,6))
set(gca,'YTick',logspace(-4,0,5))
forceNonExponentialTick

axis square
xlabel('reward','Interpreter','latex')
ylabel('$k$ (days$^{-1}$)','Interpreter','latex')
return
