% testMyerson approach

%% Setup
cd('~/git-local/delay-discounting-analysis/demo')
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

nSamples = 10^4;
nChains = 4;

%% Load data
fnames={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt',...
'NA-kirby27-DAYS.txt',...
'SB-kirby27-DAYS.txt',...
'bv-kirby27.txt',...
'rm-kirby27.txt',...
'vs-kirby27.txt',...
'BL-kirby27.txt',...
'EP-kirby27.txt',...
'JR-kirby27.txt',...
'KA-kirby27.txt',...
'LJ-kirby27.txt',...
'LY-kirby27.txt',...
'SK-kirby27.txt',...
'VD-kirby27.txt'};

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);



%% test plotting
figure(1), clf
z = ceil(sqrt(myData.nParticipants));

for n=1:myData.nParticipants
	subplot(z,z,n)
	
	% get participant data
	data = myData.getParticipantData(n);
	
	% Calculate kindif column
	data.logkindiff = log( ((data.B ./ data.A)-1) ./ data.DB );
	
	plot( data.logkindiff, data.R , 'k+')
	
	xlabel('$\log(k_{indif})$', 'Interpreter','Latex')
	ylabel('P(choose delayed)', 'Interpreter','Latex')
	box off
	drawnow
end


