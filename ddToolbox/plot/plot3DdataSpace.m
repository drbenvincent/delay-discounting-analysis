function plot3DdataSpace(data, modeVals)

opts.maxlogB	= max( abs(data.B) ); 
opts.maxD		= max( data.DB );
%% PLOT DISCOUNT SURFACE ---------------------
if ~isempty(modeVals)
	m=modeVals(1);
	c=modeVals(2);
	[logB,D,AB] = plotDiscountSurface(m, c, opts);
	hold on
end
% -------------------------------------------


% find unique experimental designs
D=[abs(data.A), abs(data.B), data.DA, data.DB]; 
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

	x(n) = abs(data.B( ia(n) )); % £B
	y(n) = data.DB( ia(n) ); % delay to get £B
	z(n) = abs(data.A( ia(n) )) ./ abs(data.B( ia(n) ));
end

% plot
for i=1:max(ic)
	h = stem3(x(i), y(i), z(i));
	h.Color='k';
	h.MarkerFaceColor=[1 1 1] .* (1-COL(i));
	h.MarkerSize = F(i)+4;
	hold on
end
	
xlabel('$|B|$', 'interpreter','Latex')
ylabel('$D^B$', 'interpreter','Latex')
zlabel('$|A|/|B|$', 'interpreter','Latex')

zlim([0 1])
% set x axis (B) to log scale
set(gca,'XScale','log')
axis vis3d
set(gca,'YDir','reverse')

return