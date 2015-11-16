function [logB,D,AB] = calculateDiscountSurface(m,c, opts)
%
% [B,D,AB] = calculateDiscountSurface(-1, 10^-1);


%% x-axis = b
% *** TODO: DOCUMENT WHAT THIS DOES ***
nIndifferenceLines = 10;
p=1; while opts.maxlogB > 10^p; p=p+1; end
logbvec=log(logspace(1,p,nIndifferenceLines));

%% y-axis = d
dvec=linspace(0,opts.maxD,25);

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

set(gca,'XTick',logspace(1,p,p-1+1))

%forceNonExponentialTick

% shading
hmesh.FaceColor		='interp';
hmesh.FaceAlpha		=0.7;
% edges
hmesh.MeshStyle		='column';
hmesh.EdgeColor		='k';
hmesh.EdgeAlpha		=1;
