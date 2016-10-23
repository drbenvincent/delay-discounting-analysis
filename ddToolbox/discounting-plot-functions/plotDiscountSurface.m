function [logB,D,AB] = plotDiscountSurface(plotdata)

% TODO: This plotting function will break if there is any change to the arrangement of data in plotdata structure.
% checks
if isempty(plotdata.samples.posterior.m)...
		|| any(isnan(plotdata.samples.posterior.m(:)))...
		|| isempty(plotdata.samples.posterior.c)...
		|| any(isnan(plotdata.samples.posterior.c(:)))
	warning('invalid or no (m,c) samples provided')
	return
end

global pow

%% High level plot logic
plotSurface()
plotData(); 
formatAxes()


	function truefalse = front_end_delays_present()
		truefalse = any(plotdata.data.rawdata.DA>0);
	end

	function plotSurface()
		
        %% Calculate point estimates
        mcBivariate = mcmc.BivariateDistribution(plotdata.samples.posterior.m, plotdata.samples.posterior.c,...
        	'shouldPlot',false,...
        	'pointEstimateType', plotdata.pointEstimateType);
        mc = mcBivariate.(plotdata.pointEstimateType);
        m = mc(1);
        c = mc(2);
        
        
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
        
        if isempty(plotdata.data.rawdata) || front_end_delays_present()
            return
        end
        
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



function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers(data)
% find unique experimental designs
D=[abs(data.A), abs(data.B), data.DA, data.DB];
[C, ia, ic] = unique(D,'rows');
% loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset=ic==n;
	% markerSize = number of times this design has been run
	markerSize(n) = sum(myset);
	% Colour = proportion of times participant chose immediate for that design
	markerCol(n) = sum(data.R(myset)==0) ./ markerSize(n);
	
	x(n) = abs(data.B( ia(n) )); % £B
	y(n) = data.DB( ia(n) ); % delay to get £B
	z(n) = abs(data.A( ia(n) )) ./ abs(data.B( ia(n) ));
end
end
