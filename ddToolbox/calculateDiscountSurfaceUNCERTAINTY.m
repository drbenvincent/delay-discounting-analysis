function [logB,D,AB] = calculateDiscountSurfaceUNCERTAINTY(m,c, opts)
%
% This takes in mcmc samples of m and c to create one discount surface for
% every MCMC sample. 
% This is then visualised as a 3D volume

if numel(m)~=numel(c)
	error('There should be equal number of MCMC samples for m and c')
else
	nSamples = numel(m);
end

%% x-axis = b
nIndifferenceLines = 5; 
p=1; while opts.maxlogB > 10^p; p=p+1; end
logbvec=log(logspace(1,p,nIndifferenceLines));

%% y-axis = d
dvec=linspace(0,opts.maxD,25);

%% create x,y (b,d) grid values
[logB,D] = meshgrid((logbvec),dvec);

%% z-axis (AB)
% Calculate the indifference point (AB) for all these values of D and logB,
% but repeat this for all MCMC samples
AB=zeros([size(D) nSamples]); % preallocation
for s = 1:nSamples
	k		= exp( m(s) .* logB + c(s) );
	AB(:,:,s)		= 1 ./ (1 + k.*D);
end

% Now we have to turn this into a 3D volumetric dataset. We need to bin the
% AB values
s=size(AB);
ABvec = linspace(0,1,40);
VOL = zeros([s(1) s(2) numel(ABvec)]);
for x=1:s(1)
	for y=1:s(2)
		[n,~] = hist( vec(squeeze(AB(x,y,:))) , ABvec);
		VOL(x,y,:) = n;
	end
end

% Now do volume visualisation ------
sx = [0:10:nIndifferenceLines];
h = slice(exp(logbvec), dvec, ABvec,...
	VOL,...
	exp(logbvec),[],[]); set(gca,'YDir','reverse')
%h = slice(VOL,[],sx,[]);
% ----------------------------------

set(h,'FaceAlpha','0.8',...
	'EdgeColor','none')
set(gca,'XScale','log')
colormap(flipud(gray))
axis vis3d, axis tight, axis square
xlabel('B'), ylabel('D'), zlabel('A/V')
view([-45, 34])

%set(gca,'XScale','log')


%zlim([0 1])
%set(gca,'XTick',logspace(1,p,p-1+1))

forceNonExponentialTick

title('THIS IS NOT WORKING?')

% %% shading
% hmesh.FaceColor='interp';
% hmesh.FaceAlpha=0.7;
% % edges
% % hmesh.EdgeColor='none';
% % hmesh.EdgeAlpha=0.7;
% hmesh.MeshStyle		='row';
% hmesh.EdgeColor		='k';
% hmesh.EdgeAlpha		=1;
% %hmesh.LineWidth		=2;