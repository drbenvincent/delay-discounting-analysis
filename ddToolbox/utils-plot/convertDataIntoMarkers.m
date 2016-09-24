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
