function plotDiscountingData(data)

opts.maxlogB	= max( abs(data.B) );
opts.maxD		= max( data.DB );

plotData()

    function plotData()
      [x,y,~,markerCol,markerSize] = convertDataIntoMarkers();

      hold on
      for i=1:numel(x)
      	h = plot(x(i), y(i),'o');
      	h.Color='k';
      	h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
      	h.MarkerSize = markerSize(i)+4;
      	hold on
      end
    end

    function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers() % TODO: make this a method of Data class?
        % find unique experimental designs
        D=[abs(data.A), abs(data.B), data.DA, data.DB];
        [C, ia, ic] = unique(D,'rows');
        %loop over unique designs (ic)
        for n=1:max(ic)
        	% binary set of which trials this design was used on
        	myset=ic==n;
        	% Size = number of times this design has been run
        	markerSize(n) = sum(myset);
        	% Colour = proportion of times that participant chose immediate
        	% for that design
        	markerCol(n) = sum(data.R(myset)==0) ./ markerSize(n);

        	%x(n) = abs(p.Results.data.B( ia(n) )); % £B
        	x(n) = data.DB( ia(n) ); % delay to get £B
        	y(n) = abs(data.A( ia(n) )) ./ abs(data.B( ia(n) ));
		end
		z=[];
    end

    function formatAxes()
      xlabel('delay, $D^B$', 'interpreter','Latex')
      xlim([0 opts.maxD*1.1])
      box off

    %   xlabel('$|reward|$', 'interpreter','latex')
    %   ylabel('delay $D^B$', 'interpreter','latex')
    %   zlabel('discount factor', 'interpreter','latex')
    end


end
