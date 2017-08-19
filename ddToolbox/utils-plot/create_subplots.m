function subplot_handles = create_subplots(N, facetStyle)
%CREATE_SUBPLOTS
% This function creates a spatial layout of N subplots with the facetStyle
% provided. It returns a set of handles.
% `facetStyle` = {'row' | 'col' | 'square'}

assert(isscalar(N))
assert(ischar(facetStyle))

subplot_handles = zeros(N,1);

switch(facetStyle)
	
	case{'row'}
		rows = 1;
		cols = N;
		subplot_handles = create_subplot_handles(rows,cols, N);
		
	case{'col'}
		rows = N;
		cols = 1;
		subplot_handles = create_subplot_handles(rows,cols, N);
		
	case{'square'}
		cols = ceil(sqrt(N));
		rows = max(1,floor(N/cols));
        while rows*cols < N
            cols = cols + 1;
        end
		subplot_handles = create_subplot_handles(rows,cols, N);
end

end

function subplot_handles = create_subplot_handles(rows,cols, N)
for n = 1:N
	subplot_handles(n) = subplot(rows, cols, n);
end
end