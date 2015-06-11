clear

% %% define model
% discountFunction = @(b,k,d) b./(1+k*d);
% %indiffPoint = @(a,k,d) a+a*k*d;

%% define params of participant

sigma=2
lambda =0;


hf=figure(1)

clf, colormap(gray)

hf.Color='w'


D=linspace(0,200,200);



hold on
k=1/120
V = 1./(1+k*D);
plot(D,V,'k-','LineWidth',2)

k=1/130
V = 1./(1+k*D);
plot(D,V,'k-','LineWidth',2)

k=1/110
V = 1./(1+k*D);
plot(D,V,'k-','LineWidth',2)

ha=gca;

ha.FontSize=16;


hold on
% plot some explanatory points
D=[50 100 150 200]
V=linspace(0.25,0.75,7);
for d=1:numel(D)
	for v=1:numel(V)
		% decision
		response = V(v) <  1./(1+k*D(d));
		% 10% change of making mistake
		if rand<0.1
			response=1-response;
		end
		% plot
		if response==1
			plot(D(d),V(v),'ko','MarkerFaceColor','k')
		else
			plot(D(d),V(v),'ko','MarkerFaceColor','w')
		end
	end
end

xlabel('delay (D)')
ylabel('A/B')
title('Would you prefer £A now, or £B in D days?')


box off

ha.LineWidth=2

% write equation
%hEqn=add_text_to_figure('BL',...
%	{'$V=\frac{1} {1+k.D}$'},...
%	20, 'latex');

ha.PlotBoxAspectRatio=[1.5 1 1];

%set(ha,'PlotBoxAspectRatio',[1.5 1 1])
ylim([0 1])


annotation('textarrow',[1,0.8],[1,0.2],...
           'String','Straight Line ')

add_text_to_figure('TR','choose immediate (£A)',16)
add_text_to_figure('BL','choose delayed (£B)',16)

% % Add arrow
% xlim([0 210])
% myarrow([205 205],[0.8 0.2])


%% EXPORT

cd('figs')
%latex_fig(12, 4,3)
export_fig explanatory -png -m6
hgsave('explanatory')
cd ..

