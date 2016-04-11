function [logB,D,AB] = plotDiscountSurface(mcParams, opts, varargin)

% TODO clean up this function

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('mcParams',@isvector);
p.addRequired('opts',@isstruct);
% p.addParameter('xScale','linear',@isstr);
p.addParameter('data',[],@isstruct)
p.parse(mcParams, opts, varargin{:});

m = p.Results.mcParams(1);
c = p.Results.mcParams(2);

%% x-axis = b
% *** TODO: DOCUMENT WHAT THIS DOES ***
nIndifferenceLines = 10;
pow=1; while opts.maxlogB > 10^pow; pow=pow+1; end
logbvec=log(logspace(1,pow,nIndifferenceLines));

%% y-axis = d
dvec=linspace(0,opts.maxD,100);

%% create x,y (b,d) grid values
[logB,D] = meshgrid(logbvec,dvec);

%% z-axis (AB)
k		= exp(m .* logB + c);
AB		= 1 ./ (1 + k.*D);

%% PLOT
hmesh = mesh(exp(logB),D,AB);
% formatting
set(gca,'YDir','reverse')
axis vis3d
axis tight
axis square
xlabel('$|reward|$', 'interpreter','latex')
ylabel('$D$', 'interpreter','latex')
zlabel('discount factor', 'interpreter','latex')
zlim([0 1])

view([-45, 34])
set(gca,'XScale','log')

set(gca,'XTick',logspace(1,pow,pow-1+1))

%forceNonExponentialTick

% shading
hmesh.FaceColor		='interp';
hmesh.FaceAlpha		=0.7;
% edges
hmesh.MeshStyle		='column';
hmesh.EdgeColor		='k';
hmesh.EdgeAlpha		=1;



hold on


if ~isempty(p.Results.data)
  opts.maxlogB	= max( abs(p.Results.data.B) );
  opts.maxD		= max( p.Results.data.DB );
%   %% PLOT DISCOUNT SURFACE ---------------------
%   if ~isempty(modeVals)
%   	m=modeVals(1);
%   	c=modeVals(2);
%   	[logB,D,AB] = plotDiscountSurface(m, c, opts);
%   	hold on
%   end
%   % -------------------------------------------


  % find unique experimental designs
  D=[abs(p.Results.data.A), abs(p.Results.data.B), p.Results.data.DA, p.Results.data.DB];
  [C, ia, ic] = unique(D,'rows');
  %loop over unique designs (ic)
  for n=1:max(ic)
  	% binary set of which trials this design was used on
  	myset=ic==n;
  	% Size = number of times this design has been run
  	F(n) = sum(myset);
  	% Colour = proportion of times that participant chose immediate
  	% for that design
  	COL(n) = sum(p.Results.data.R(myset)==0) ./ F(n);

  	x(n) = abs(p.Results.data.B( ia(n) )); % £B
  	y(n) = p.Results.data.DB( ia(n) ); % delay to get £B
  	z(n) = abs(p.Results.data.A( ia(n) )) ./ abs(p.Results.data.B( ia(n) ));
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
end


end
