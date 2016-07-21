function [logB,D,AB] = plotDiscountSurface(plotdata)

%% Calculate point estimates
mcBivariate = mcmc.BivariateDistribution(plotdata.samples.posterior.m, plotdata.samples.posterior.c,...
	'shouldPlot',false,...
	'pointEstimateType', plotdata.pointEstimateType);
mc = mcBivariate.(plotdata.pointEstimateType);
m = mc(1);
c = mc(2);

global pow

%% High level plot logic
plotSurface()
if ~isempty(plotdata.data.rawdata), plotData(); end
formatAxes()


  function plotSurface()
	  
	  try
		  maxlogB = max( abs( plotdata.data.rawdata.B) );
		  maxD = max(plotdata.data.rawdata.DB);
	  catch
		  maxlogB = 100;
		  maxD = 365;
	  end
		  
    %% x-axis = b
    % *** TODO: DOCUMENT WHAT THIS DOES ***
    nIndifferenceLines = 10;
    pow=1; while maxlogB > 10^pow; pow=pow+1; end
    logbvec=log(logspace(1, pow, nIndifferenceLines));

    %% y-axis = d
    dvec=linspace(0, maxD, 100);

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
    %maxlogB = max( abs( plotdata.data.rawdata.B) );
    %maxD = max(plotdata.data.rawdata.DB);

    [x,y,z,markerCol,markerSize] = convertDataIntoMarkers(plotdata.data.rawdata);

    % plot
    for i=1:numel(x)
    	h = stem3(x(i), y(i), z(i));
    	h.Color='k';
    	h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
    	h.MarkerSize = markerSize(i)+4;
    	hold on
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
