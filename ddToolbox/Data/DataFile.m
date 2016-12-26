classdef DataFile
	%DataFile A class to represent and plot data from one file/experiment.
	
	properties (SetAccess = private, GetAccess = protected)
		datatable % a structure OR TABLE
	end
	
	
	% PUBLIC METHODS ======================================================
	methods
		
		function obj = DataFile(data)
			if isempty(data)
				obj.datatable=[];
				return
			end
			assert(istable(data), 'Input must be a Table')
			obj.datatable = data;
			
			obj.removeMissingResponseTrials();
			obj.validateData();
		end
		
		
		function obj = removeMissingResponseTrials(obj)
			RESPONSE_VARIABLENAME = 'R';
			obj.datatable = obj.datatable(~isnan(obj.datatable.(RESPONSE_VARIABLENAME)),:);
		end
		
		function obj = validateData(obj)
			assert(any(obj.datatable.DA >= 0), 'Entries of DA must be greater than or equal to zero')
			assert(any(obj.datatable.DB >= 0), 'Entries of DA must be greater than or equal to zero')
			assert(any(obj.datatable.DA <= obj.datatable.DB), 'For any given trial (row) DA must be less than or equal to DB')
			assert(any(obj.datatable.PA > 0 | obj.datatable.PA < 1), 'PA must be between 0 and 1')
			assert(any(obj.datatable.PB > 0 | obj.datatable.PB < 1), 'PA must be between 0 and 1')
			assert(all(obj.datatable.R <=1 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(obj.datatable.R >=0 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(rem(obj.datatable.R,1)==0), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(isnumeric(obj.datatable.R)), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
		end
		
		function aTable = getDataAsTable(obj)
			aTable = obj.datatable;
			assert(istable(aTable))
		end
		
		function nTrials = getTrialsForThisParticant(obj)
			nTrials = height(obj.datatable);
		end
		
		function obj = plot(obj, dataPlotType, timeUnits)
			% This should be able to deal with:
			% - discount function
			% - discount surface
			
			timeUnitFunction = str2func(timeUnits);
			
			% exit if we have got no data
			if isempty(obj.datatable)
				warning('Trying to plot, but have no data. This is probably due to this being the (group/unobserved) participant, who has no data. This is only an error if you are not getting data corresponding to a specific data file.')
				return
			end
			
			% TODO: dataMarkers could even be a separate class with
			% methods:
			% - convertDataIntoMarkers()
			% - plot()
			
			
			% TODO: Refactor this to achieve it through cleverness or
			% polymorphism, not by conditionals 
			
			%isDelayedRewardHomegenous = var(obj.datatable.B)==0;
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
				r = unique(sort([obj.datatable.DA(:) ;obj.datatable.DB(:)]));
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
			D=[abs(obj.datatable.A), abs(obj.datatable.B), obj.datatable.DA, obj.datatable.DB];
			[C, ia, ic] = unique(D,'rows');
			%loop over unique designs (ic)
			for n=1:max(ic)
				% binary set of which trials this design was used on
				myset=ic==n;
				% Size = number of times this design has been run
				markerSize(n) = sum(myset);
				% Colour = proportion of times that participant chose immediate
				% for that design
				markerCol(n) = sum(obj.datatable.R(myset)==0) ./ markerSize(n);
				
				%x(n) = abs(p.Results.datatable.B( ia(n) )); % £B
				x(n) = obj.datatable.DB( ia(n) ); % delay to get £B
				y(n) = abs(obj.datatable.A( ia(n) )) ./ abs(obj.datatable.B( ia(n) ));
			end
			z=[];
		end
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers_Heterogenous(obj)
			% FOR 3D DISCOUNT FUNCTIONS
			
			
			% find unique experimental designs
			D=[abs(obj.datatable.A), abs(obj.datatable.B), obj.datatable.DA, obj.datatable.DB];
			[C, ia, ic] = unique(D,'rows');
			% loop over unique designs (ic)
			for n=1:max(ic)
				% binary set of which trials this design was used on
				myset=ic==n;
				% markerSize = number of times this design has been run
				markerSize(n) = sum(myset);
				% Colour = proportion of times participant chose immediate for that design
				markerCol(n) = sum(obj.datatable.R(myset)==0) ./ markerSize(n);
				
				x(n) = abs(obj.datatable.B( ia(n) )); % £B
				y(n) = obj.datatable.DB( ia(n) ); % delay to get £B
				z(n) = abs(obj.datatable.A( ia(n) )) ./ abs(obj.datatable.B( ia(n) ));
			end
		end
		
	end
end
