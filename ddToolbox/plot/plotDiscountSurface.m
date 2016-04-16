function [logB,D,AB] = plotDiscountSurface(mcParams, opts, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('mcParams',@isvector);
p.addRequired('opts',@isstruct);
% p.addParameter('xScale','linear',@isstr);
p.addParameter('data',[],@isstruct)
p.parse(mcParams, opts, varargin{:});

m = p.Results.mcParams(1);
c = p.Results.mcParams(2);

global pow

plotSurface()
if ~isempty(p.Results.data)
  plotData()
end
formatAxes()


  function plotSurface()
    %% x-axis = b
    % *** TODO: DOCUMENT WHAT THIS DOES ***
    nIndifferenceLines = 10;
    pow=1; while opts.maxlogB > 10^pow; pow=pow+1; end
    logbvec=log(logspace(1,pow,nIndifferenceLines));

    %% y-axis = d
    dvec=linspace(0,opts.maxD,100);

    %% z-axis (AB)
    [logB,D] = meshgrid(logbvec,dvec); % create x,y (b,d) grid values
    k		= exp(m .* logB + c); % magnitude effect
    AB		= 1 ./ (1 + k.*D); % hyperbolic discount function
    B = exp(logB);

    %% PLOT
    hmesh = mesh(B,D,AB);
    % shading
    hmesh.FaceColor		='interp';
    hmesh.FaceAlpha		=0.7;
    % edges
    hmesh.MeshStyle		='column';
    hmesh.EdgeColor		='k';
    hmesh.EdgeAlpha		=1;
  end

  function plotData()
    hold on
    opts.maxlogB	= max( abs(p.Results.data.B) );
    opts.maxD		= max( p.Results.data.DB );

    [x,y,z,markerCol,markerSize] = convertDataIntoMarkers();

    % plot
    for i=1:numel(x)
    	h = stem3(x(i), y(i), z(i));
    	h.Color='k';
    	h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
    	h.MarkerSize = markerSize(i)+4;
    	hold on
    end
  end

  function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers()
    % find unique experimental designs
    D=[abs(p.Results.data.A), abs(p.Results.data.B), p.Results.data.DA, p.Results.data.DB];
    [C, ia, ic] = unique(D,'rows');
    % loop over unique designs (ic)
    for n=1:max(ic)
      % binary set of which trials this design was used on
      myset=ic==n;
      % markerSize = number of times this design has been run
      markerSize(n) = sum(myset);
      % Colour = proportion of times participant chose immediate for that design
      markerCol(n) = sum(p.Results.data.R(myset)==0) ./ markerSize(n);

      x(n) = abs(p.Results.data.B( ia(n) )); % £B
      y(n) = p.Results.data.DB( ia(n) ); % delay to get £B
      z(n) = abs(p.Results.data.A( ia(n) )) ./ abs(p.Results.data.B( ia(n) ));
    end
  end

  function formatAxes()
    view([-45, 34])
    axis vis3d
    axis tight
    axis square
    zlim([0 1])
    set(gca,'YDir','reverse')
    set(gca,'XScale','log')
    set(gca,'XTick',logspace(1,pow,pow-1+1))

    xlabel('$|reward|$', 'interpreter','latex')
    ylabel('delay $D^B$', 'interpreter','latex')
    zlabel('discount factor', 'interpreter','latex')
  end

end
