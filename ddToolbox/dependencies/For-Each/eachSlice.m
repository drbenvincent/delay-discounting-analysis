function IO = eachSlice(A,workdim)
%EACHSLICE Loop over each an array by dividing into slices
% Use EACHSLICE(A,WORKDIM) to iterate over every slice of an array A along 
% the working dimensions. WORKDIM is a vector of integer dimensions from 
% which to extract the slices.
%
% In each iteration, ELEM is set to the next slice of A. 
%
%     for elem = EACHSLICE(A,WORKDIM)
%         % Loop Body - Your Code
%     end
%
% Example, the following is equivalent to using eachRow.
%
%     for elem = eachSlice(A,1)
%         % Loop Body - Your Code
%     end
%
% EACHSLICE can loop over arbitrary dimensions of an array.
%
% Example, loop over the color channels of an image:
%
%     rgb = imread('ngc6543a.jpg');
% 
%     i = 1; subplot(2,2,i)
%     image(rgb);axis off
% 
%     slice = 3;
%     for channel = eachSlice(rgb,slice)
%         i = i+1; subplot(2,2,i); 
%         image(channel,'CDataMapping','scaled');axis off
%         colormap(gray);
%     end
%     
% Note: for elem = eachSlice(A,WORKDIM),..,end produces N elements with the 
% following properties:
%
%    * Given siz = size(A), N = prod(siz(WORKDIM)).
%    * size(elem,K) = 1, if K is in the WORKDIM.
%    * size(elem,K) = size(A,K), otherwise.
%    * If a value in SLICE is greater than the number of dimensions in A, 
%      that dimension is assumed to be length 1
%    
%  See also each, eachColumn, eachRow, eachPage
%  

%   Copyright 2014 The MathWorks, Inc.

IO = each.iterators.ArraySliceIterator(A,workdim);
end