% generateFigure5

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
ylabel('P(choose~delayed)', 'Interpreter','latex')%% Export
% cd('figs')
% latex_fig(12, 4,3)
% export_fig explanatoryPsycho -png -m8
% hgsave('explanatoryPsycho')
% cd ..


