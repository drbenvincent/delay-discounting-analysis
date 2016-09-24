function logInfo(fid, varargin)
% Log text to a file (fid) and the command window. Call this function just
% as you would call fprintf.
fprintf( 1, varargin{:});
fprintf( fid, varargin{:});
return
