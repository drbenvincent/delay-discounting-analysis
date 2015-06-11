% plotKirbyData





% fname = 'kirby27-BV.txt'
% fname = 'kirby27-SM.txt'
% [participant, expt] = importData(fname);






%% PLOT FOR SMALL/MED/LARGE SEPERATELY
SMALL = le(participant.data.B,35);
MED = ge(participant.data.B,50) & le(participant.data.B,60);
LARGE = ge(participant.data.B,75);

x = participant.data.D;
y = participant.data.A./participant.data.B;

%figure(2), clf
hold on


% plot curves for small/medium/large delayed rewards
plot(x(SMALL),y(SMALL),'-','LineWidth',1,'Color',[0.5 0.5 0.5])
plot(x(MED),y(MED),'-','LineWidth',1,'Color',[0.5 0.5 0.5])
plot(x(LARGE),y(LARGE),'-','LineWidth',1,'Color',[0.5 0.5 0.5])

% now plot points: filled = chose delayed, open = chose immediate
del = participant.data.R==1;
imm = participant.data.R==0;
plot(x(del),y(del),'ko','MarkerFaceColor','k', 'MarkerSize',3^2)
plot(x(imm),y(imm),'ko','MarkerFaceColor','w', 'MarkerSize',3^2)

% % Legend
% l=legend({'small B','medium B','large B',...
% 	'chose delayed','choise immediate'});
% l.Location='southeast';

xlabel('Delay (D)')
ylabel('Relative value (A/B)')
%title(fname)


% %cd(plotOpts.saveDir)
% latex_fig(16, 6,4)
% figName = [participant.fname '-rawData'];
% export_fig(figName,'-png','-m3')
% hgsave(figName)
% %cd(plotOpts.rootDir)
% fprintf('Figure saved: %s', figName);








%% PLOT AS A FUNCTION OF K
returnToThis = gcf;

%% sort data by ascending kindiff -----
[~,ind]=sort(participant.data.kIndiff);
% now sort
participant.data.A = participant.data.A(ind);
participant.data.B = participant.data.B(ind);
participant.data.D = participant.data.D(ind);
participant.data.R = participant.data.R(ind);
participant.data.kIndiff = participant.data.kIndiff(ind);
% ----------------------------------
% Recalculate set
SMALL = le(participant.data.B,35);
MED = ge(participant.data.B,50) & le(participant.data.B,60);
LARGE = ge(participant.data.B,75);
% ----------------------------------

figure(13)
clf
x=(participant.data.kIndiff);
y=participant.data.R;

subplot(3,1,1), semilogx(x(SMALL),y(SMALL),'k:o','LineWidth',3)
add_text_to_figure('TL','small B', 12)

subplot(3,1,2), semilogx(x(MED),y(MED),'k--o','LineWidth',3)
add_text_to_figure('TL','medium B', 12)

subplot(3,1,3), semilogx(x(LARGE),y(LARGE),'k-o','LineWidth',3)
add_text_to_figure('TL','large B', 12)


xlabel('Question, implied k at indifference')
ylabel('P(choose delayed)')

% %cd(plotOpts.saveDir)
latex_fig(16, 6,6)
figName = [participant.fname '-rawDataKFUNC'];
export_fig(figName,'-png','-m3')
% hgsave(figName)
% %cd(plotOpts.rootDir)




figure(returnToThis)
