% plotfigPsychometricDemo

clf

VminusA = linspace(-20,20,1000);

errorRate	= [0 0 0.2 0.2];
sigma		= [0 5 0 5]
titles={'a', 'b', 'c', 'd'};

for n=1:4
	s(n) = subplot(2,2,n);
	
	Pdel = errorRate(n)+(1-2*errorRate(n)) * normcdf(VminusA, 0, sigma(n));
	hLine(n) = plot(VminusA, Pdel,...
		'k-',...
		'LineWidth',2);
	
	box off
	
	switch n
		case{3,4}
			s(n).YTick	=[0 errorRate(n) 0.5 1-errorRate(n) 1];
			s(n).YTickLabel={'0', '\epsilon', '0.5', '1-\epsilon', '1'};
	end
	
	
	s(n).YLim		=[0 1];
	s(n).XTick		=[-20:10:20];
	%title(titles(n))
	
	add_text_to_figure('TL',sprintf('  %s',titles{n}), 16)
end
subplot(2,2,3)
xlabel('$V-A$', 'Interpreter','latex')
ylabel('P(choose~delayed)', 'Interpreter','latex')


% subplot(2,2,1), title('good comparison accuity (\sigma=0)')
% subplot(2,2,2), title('bad comparison accuity (\sigma=5)')



%% Formatting
% 
% 
% 
% % set axis properties
% for n=1:numel(s)
% 	axisHandle			= s(n);
% 	axisHandle.YLim		=[0 1];
% 	axisHandle.box = 'off';
% 	%axisHandle.YTick	=[0 errorRate 0.5 1-errorRate 1];
% 	%axisHandle.YTickLabel={'0', '\epsilon', '0.5', '1-\epsilon', '1'};
% end
% 
% for n=3:4
% 	axisHandle.YTickLabel={'0', '\epsilon', '0.5', '1-\epsilon', '1'};
% end
% 
% % line colours
% hLine(1).Color=[0.3 0.3 0.3];
% hLine(2).Color=[1/2 1/2 1/2];
% hLine(3).Color=[0.7 0.7 0.7];
% 
% 
% set(gca,'TickDirMode','manual')
% set(gca,'TickDir','out')
% set(gca,'Box','off')
% 
% 
% % legend
% lh			= legend(sigmavec)
% lh.Box		='off'
% lh.Location ='SouthEast'

%% Export
cd('figs')
latex_fig(12, 4,3)
export_fig explanatoryPsycho -png -m8
hgsave('explanatoryPsycho')
cd ..


