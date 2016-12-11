classdef DataFile
	%DataFile A class to represent and plot data from one file/experiment.
	
	properties (GetAccess = private, SetAccess = private)
		data % a structure
	end
	
	
	% PUBLIC METHODS ======================================================
	methods
		
		function obj = DataFile(data)
			if isempty(data)
				obj.data=[];
				return
			end
			assert(isstruct(data),'Must provide a structure as input')
			obj.data = data;
		end
		
		
		
		
		function obj = plot(obj, dataPlotType)
			% This should be able to deal with:
			% - discount function
			% - discount surface
			
			timeUnitFunction = @days; % <---------- TODO: inject this @days function
			
			% exit if we have got no data
			if isempty(obj.data)
				warning('Trying to plot, but have no data.')
				return
			end
			
			% TODO: dataMarkers could even be a separate class with
			% methods:
			% - convertDataIntoMarkers()
			% - plot()
			
			
			% TODO: Refactor this to achieve it through cleverness or
			% polymorphism, not by conditionals 
			
			%isDelayedRewardHomegenous = var(obj.data.B)==0;
			switch dataPlotType
				case{'2D'}
					
					%if isDelayedRewardHomegenous % --------------------------------
					% plot 2D discount function
					[x,y,z,markerCol,markerSize] =...
						obj.convertDataIntoMarkers_Homogenous();
					
					% TODO: Extract into function ------------
					hold on
					for i=1:numel(x)
						h = plot(timeUnitFunction(x(i)), y(i), 'o');
						h.Color='k';
						h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
						h.MarkerSize = markerSize(i)+4;
						hold on
					end
					
					% zoom axis to marker range
					set(gca,'XLim',[0 timeUnitFunction( max(x)*1.2) ] )
					set(gca,'YLim',[0 max(y)*1.1])
					
					%else % --------------------------------------------------------
					
				case{'3D'}
					% plot 3D discount surface
					[delayedRewardMagnitude, delay,discountFraction, markerCol, markerSize] =...
						obj.convertDataIntoMarkers_Heterogenous();
					
					% TODO: Extract into function ------------
					hold on
					for i=1:numel(delayedRewardMagnitude)
						% currently, stem3 cannot accept Duration inputs,
						% so we will use plot3 instead
						% h = stem3(delayedRewardMagnitude(i),...
						%		timeUnitFunction(delay(i)),...
						%		discountFraction(i));
						
						% Stem
						plot3([delayedRewardMagnitude(i) delayedRewardMagnitude(i)],...
							[timeUnitFunction(delay(i)) timeUnitFunction(delay(i))],...
							[discountFraction(i) 0], 'k-')
						% Marker
						h = plot3(delayedRewardMagnitude(i),...
							timeUnitFunction(delay(i)),...
							discountFraction(i), 'o');
						h.Color='k';
						h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
						h.MarkerSize = markerSize(i)+4;
						
					end
					
					% Crop axes around data
					set(gca,'XLim',[min(delayedRewardMagnitude) max(delayedRewardMagnitude)*1.1])
					set(gca,'YLim',[0 timeUnitFunction(max(delay))*1.2])
			end
			
		end
		
		
		function r = getDelayRange(obj)
			try
				r = unique(sort([obj.data.DA(:) ;obj.data.DB(:)]));
			catch
				% probably because of absence of data
				r = [];
			end
		end
		
		
	end
	
	
	
	
	% PRIVATE METHODS =====================================================
	
	methods(Access = protected)
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers_Homogenous(obj)
			% FOR 2D DISCOUNT FUNCTIONS
			
			% find unique experimental designs
			D=[abs(obj.data.A), abs(obj.data.B), obj.data.DA, obj.data.DB];
			[C, ia, ic] = unique(D,'rows');
			%loop over unique designs (ic)
			for n=1:max(ic)
				% binary set of which trials this design was used on
				myset=ic==n;
				% Size = number of times this design has been run
				markerSize(n) = sum(myset);
				% Colour = proportion of times that participant chose immediate
				% for that design
				markerCol(n) = sum(obj.data.R(myset)==0) ./ markerSize(n);
				
				%x(n) = abs(p.Results.data.B( ia(n) )); % £B
				x(n) = obj.data.DB( ia(n) ); % delay to get £B
				y(n) = abs(obj.data.A( ia(n) )) ./ abs(obj.data.B( ia(n) ));
			end
			z=[];
		end
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers_Heterogenous(obj)
			% FOR 3D DISCOUNT FUNCTIONS
			
			
			% find unique experimental designs
			D=[abs(obj.data.A), abs(obj.data.B), obj.data.DA, obj.data.DB];
			[C, ia, ic] = unique(D,'rows');
			% loop over unique designs (ic)
			for n=1:max(ic)
				% binary set of which trials this design was used on
				myset=ic==n;
				% markerSize = number of times this design has been run
				markerSize(n) = sum(myset);
				% Colour = proportion of times participant chose immediate for that design
				markerCol(n) = sum(obj.data.R(myset)==0) ./ markerSize(n);
				
				x(n) = abs(obj.data.B( ia(n) )); % £B
				y(n) = obj.data.DB( ia(n) ); % delay to get £B
				z(n) = abs(obj.data.A( ia(n) )) ./ abs(obj.data.B( ia(n) ));
			end
		end
		
	end
end
