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

% find unique experimental designs
D=[data.A, data.B, data.DA, data.DB]; 
[C, ia, ic] = unique(D,'rows');
%loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset=ic==n;
	% Size = number of times this design has been run
	F(n) = sum(myset);
	% Colour = proportion of times that participant chose immediate
	% for that design
	COL(n) = sum(data.R(myset)==0) ./ F(n);

	x(n) = data.B( ia(n) ); % £B
	y(n) = data.DB( ia(n) ); % delay to get £B
	z(n) = data.A( ia(n) ) ./ data.B( ia(n) );
end

% plot
for i=1:max(ic)
	h = stem3(x(i), y(i), z(i));
	h.Color='k';
	h.MarkerFaceColor=[1 1 1] .* (1-COL(i));
	h.MarkerSize = F(i)+4;
	hold on
end
	
xlabel('B')
ylabel('D^B')
zlabel('A/B')

zlim([0 1])
% set x axis (B) to log scale
set(gca,'XScale','log')
axis vis3d
set(gca,'YDir','reverse')
			
% % plot chose imm
% hImm = stem3(data.B(imm==1),...
% 	data.DB(imm==1),...
% 	data.A(imm==1) ./ data.B(imm==1));
% hImm.MarkerFaceColor = 'w';
% hImm.Color = 'k';
% hold on
% % plot chose delayed
% hDel = stem3(data.B(del==1),...
% 	data.DB(del==1),...
% 	data.A(del==1) ./ data.B(del==1));
% hDel.MarkerFaceColor = 'k';
% hDel.Color = 'k';
% 
% % set x axis (B) to log scale
% set(gca,'XScale','log')
% %set(gca,'XTick',[10 50 100 200 500 1000])
% 
% 
% 
% xlabel('B')
% ylabel('D')
% zlabel('A/B ratio')
% axis vis3d
% zlim([0 1])
% % view([-135 34])
% % set(gca,'XDir','reverse')
% set(gca,'YDir','reverse')
% 
%  beep

return