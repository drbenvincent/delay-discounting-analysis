function plot3DdataSpace(data, modeVals)

opts.maxlogB	= max( data.B ); 
opts.maxD		= max( data.DB );
%% PLOT DISCOUNT SURFACE ---------------------
%m=-1; c=10^-1;
if numel(modeVals)>0
	m=modeVals(1);
	c=modeVals(2);
	[logB,D,AB] = calculateDiscountSurface(m, c, opts);
	hold on
end
% -------------------------------------------

%% Plot data
imm = data.R==0;
del = data.R==1;

% plot chose imm
hImm = stem3(data.B(imm==1),...
	data.DB(imm==1),...
	data.A(imm==1) ./ data.B(imm==1));
hImm.MarkerFaceColor = 'w';
hImm.Color = 'k';
hold on
% plot chose delayed
hDel = stem3(data.B(del==1),...
	data.DB(del==1),...
	data.A(del==1) ./ data.B(del==1));
hDel.MarkerFaceColor = 'k';
hDel.Color = 'k';

% set x axis (B) to log scale
set(gca,'XScale','log')
%set(gca,'XTick',[10 50 100 200 500 1000])



xlabel('B')
ylabel('D')
zlabel('A/B ratio')
axis vis3d
zlim([0 1])
% view([-135 34])
% set(gca,'XDir','reverse')
set(gca,'YDir','reverse')

 beep

return