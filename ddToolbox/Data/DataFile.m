classdef DataFile
	%DataFile A class to hold and plot data from one file/experiment.
	
	properties (SetAccess = private, GetAccess = protected)
		datatable
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
			
			% TODO: throw error if we have no data
		end
		
		function obj = plot(obj, dataPlotType, timeUnits)
			% This should be able to deal with:
			% - discount function
			% - discount surface
			
			if verLessThan('matlab','9.1') % backward compatability
				timeUnitFunction = @(x) x; % do nothing
			else
				timeUnitFunction = str2func(timeUnits);
			end

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
		
        % PUBLIC GETTERS =======================================================
		
        function aTable = getDataAsTable(obj)
            aTable = obj.datatable;
            assert(istable(aTable))
        end
        
		function r = getUniqueDelays(obj)
			try
				r = unique(sort([obj.datatable.DA(:) ;obj.datatable.DB(:)]));
			catch
				% probably because of absence of data
				r = [];
			end
		end
		
	end
	
	
	
	% ======================================================================
	% PRIVATE METHODS =====================================================
	% ======================================================================
    
	methods(Access = protected)
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers_Homogenous(obj)
			% FOR 2D DISCOUNT FUNCTIONS
			[ia, ic] = obj.calcUniqueDesigns();
            markerSize = obj.calcMarkerSize(ic);
            markerCol = obj.calcMarkerCol(ic);
            
			for n=1:max(ic)
				x(n) = obj.datatable.DB( ia(n) ); % delay to get B
				y(n) = abs(obj.datatable.A( ia(n) )) ./ abs(obj.datatable.B( ia(n) ));
			end
			z = [];
		end
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers_Heterogenous(obj)
			% FOR 3D DISCOUNT FUNCTIONS
            [ia, ic] = obj.calcUniqueDesigns();
            markerSize = obj.calcMarkerSize(ic);
            markerCol = obj.calcMarkerCol(ic);
			for n=1:max(ic)
				x(n) = abs(obj.datatable.B( ia(n) )); % B
				y(n) = obj.datatable.DB( ia(n) ); % delay to get B
				z(n) = abs(obj.datatable.A( ia(n) )) ./ abs(obj.datatable.B( ia(n) ));
			end
		end
        
        function [ia, ic] = calcUniqueDesigns(obj)
            designs = [abs(obj.datatable.A), abs(obj.datatable.B), obj.datatable.DA, obj.datatable.DB];
            [C, ia, ic] = unique(designs,'rows');
        end
        
        function markerSize = calcMarkerSize(obj, ic)
            for n=1:max(ic)
                markerSize(n) = obj.nDesignOccurrences(ic, n);
            end
        end
        
        function markerCol = calcMarkerCol(obj, ic)
            % Colour = prop. of times they chose immediate, for that design
            for n=1:max(ic)
                markerCol(n) = obj.nChoseImmediate(obj.datatable.R, ic, n)...
					./ obj.nDesignOccurrences(ic, n);
            end
		end
        
	end
    
    methods(Static)
    
		function nImmediateChoicesMade = nChoseImmediate(responses, ic, n)
			nImmediateChoicesMade = sum(responses(ic==n)==0);
		end
		
        function nOccurrences = nDesignOccurrences(ic, n)
            nOccurrences = sum(ic==n);
        end

    end
end
