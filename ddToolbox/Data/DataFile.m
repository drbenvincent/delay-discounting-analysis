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
		
		
		
		
		function obj = plot(obj)
			
			% exit if we have got no data
			if isempty(obj.data)
				warning('Trying to plot, but have no data.')
				return
			end
			
			[x,y,~,markerCol,markerSize] = obj.convertDataIntoMarkers();
			
			hold on
			for i=1:numel(x)
				h = plot(x(i), y(i),'o');
				h.Color='k';
				h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
				h.MarkerSize = markerSize(i)+4;
				hold on
			end
			
		end
		
		
		
		
		
	end
	
	
	
	% PRIVATE METHODS =====================================================
	
	methods(Access = protected)
		
		function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers(obj)
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
		
	end
end
