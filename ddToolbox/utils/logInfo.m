function logInfo(fid, Str, vargargin)
% Log textto a file (fid) and the command windown. Call this function just
% as you would call fprintf.
if nargin == 2
	fprintf(  1, Str);
	fprintf(fid, Str);
elseif nargin > 2
	fprintf(  1, Str, vargargin);
	fprintf(fid, Str, vargargin);
end
return;