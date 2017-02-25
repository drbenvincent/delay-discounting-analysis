function subplot_handles = create_subplots(N, facetStyle)
%CREATE_SUBPLOTS
% This function creates a spatial layout of N subplots with the facetStyle
% provided. It returns a set of handles.

assert(isscalar(N))
assert(ischar(facetStyle))

subplot_handles = zeros(N,1);

% CREATE SUBPLOTS

switch(facetStyle)
	
	case{'row'}
		rows = 1;
		cols = N;
		
		% arrayfun(@(x) subplot(rows, cols, x), [1:5])
		for n = 1:N
			subplot_handles(n) = subplot(rows, cols, n);
		end
		
	case{'col'}
		rows = N;
		cols = 1;
		for n = 1:N
			subplot_handles(n) = subplot(rows, cols, n);
		end
		
	case{'square'}
		cols = ceil(sqrt(N));
		rows = max(1,floor(N/cols));
        while rows*cols < N
            cols = cols + 1;
        end
		for n = 1:N
			subplot_handles(n) = subplot(rows, cols, n);
		end
end
