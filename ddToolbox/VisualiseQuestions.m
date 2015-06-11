% VisualiseQuestions

figure(1), clf

rows = 2;
cols = 4;
n=1
subplot(rows,cols,n), generateQuestions('Kirby27'); n=n+1;
subplot(rows,cols,n), generateQuestions('ABslice'); n=n+1;
subplot(rows,cols,n), generateQuestions('Dslice'); n=n+1;
subplot(rows,cols,n), generateQuestions('Dshotgun'); n=n+1;
subplot(rows,cols,n), generateQuestions('Bslice'); n=n+1;
subplot(rows,cols,n), generateQuestions('BsliceRD'); n=n+1;
subplot(rows,cols,n), generateQuestions('BSLICES'); n=n+1;


%% Export Figure

cd('figs')
latex_fig(16, 10, 10)
figName = 'ALL QUESTIONS';
export_fig(figName,'-png','-m3')
hgsave(figName)
cd('..')
fprintf('Figure saved: %s\n\n', figName);