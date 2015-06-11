function [Hout Xbins Ybins] = hist2d(D, varargin) %Xn, Yn, Xrange, Yrange)
%HIST2D 2D histogram
%
% [H XBINS YBINS] = HIST2D(D, XN, YN, [XLO XHI], [YLO YHI])
% [H XBINS YBINS] = HIST2D(D, 'display' ...)
%
% HIST2D calculates a 2-dimensional histogram and returns the histogram
% array and (optionally) the bins used to calculate the histogram.
%
% Inputs:
%     D:         N x 2 real array containing N data points or N x 1 array 
%                 of N complex values 
%     XN:        number of bins in the x dimension (defaults to 20)
%     YN:        number of bins in the y dimension (defaults to 20)
%     [XLO XHI]: range for the bins in the x dimension (defaults to the 
%                 minimum and maximum of the data points)
%     [YLO YHI]: range for the bins in the y dimension (defaults to the 
%                 minimum and maximum of the data points)
%     'display': displays the 2D histogram as a surf plot in the current
%                 axes
%
% Outputs:
%     H:         2D histogram array (rows represent X, columns represent Y)
%     XBINS:     the X bin edges (see below)
%     YBINS:     the Y bin edges (see below)
%       
% As with histc, h(i,j) is the number of data points (dx,dy) where 
% x(i) <= dx < x(i+1) and y(j) <= dx < y(j+1). The last x bin counts 
% values where dx exactly equals the last x bin value, and the last y bin 
% counts values where dy exactly equals the last y bin value.
%
% If D is a complex array, HIST2D splits the complex numbers into real (x) 
% and imaginary (y) components.
%
% Created by Amanda Ng on 5 December 2008

% Modification history
%   25 March 2009 - fixed error when min and max of ranges are equal.
%   22 November 2009 - added display option; modified code to handle 1 bin

    % PROCESS INPUT D
    if nargin < 1 %check D is specified
        error 'Input D not specified'
    end
    
    Dcomplex = false;
    if ~isreal(D) %if D is complex ...
        if isvector(D) %if D is a vector, split into real and imaginary
            D=[real(D(:)) imag(D(:))];
        else %throw error
            error 'D must be either a complex vector or nx2 real array'
        end
        Dcomplex = true;
    end

    if (size(D,1)<size(D,2) && size(D,1)>1)
        D=D';
    end
    
    if size(D,2)~=2;
        error('The input data matrix must have 2 rows or 2 columns');
    end
    
    % PROCESS OTHER INPUTS
    var = varargin;

    % check if DISPLAY is specified
    index = find(strcmpi(var,'display'));
    if ~isempty(index)
        display = true;
        var(index) = [];
    else
        display = false;
    end

    % process number of bins    
    Xn = 100; %default
    Xndefault = true;
    if numel(var)>=1 && ~isempty(var{1}) % Xn is specified
        if ~isscalar(var{1})
            error 'Xn must be scalar'
%         elseif var{1}<1 || ~isinteger(var{1})
%             error 'Xn must be an integer greater than or equal to 1'
        else
            Xn = var{1};
            Xndefault = false;
        end
    end

    Yn = 100; %default
    Yndefault = true;
    if numel(var)>=2 && ~isempty(var{2}) % Yn is specified
        if ~isscalar(var{2})
            error 'Yn must be scalar'
%         elseif var{2}<1 || ~isinteger(var{2})
%             error 'Xn must be an integer greater than or equal to 1'
        else
            Yn = var{2};
            Yndefault = false;
        end
    end
    
    % process ranges
    if numel(var) < 3 || isempty(var{3}) %if XRange not specified
        Xrange=[min(D(:,1)),max(D(:,1))]; %default
    else
        if nnz(size(var{3})==[1 2]) ~= 2 %check is 1x2 array
            error 'XRange must be 1x2 array'
        end
        Xrange = var{3};
    end
    if Xrange(1)==Xrange(2) %handle case where XLO==XHI
        if Xndefault
            Xn = 1;
        else
            Xrange(1) = Xrange(1) - floor(Xn/2);
            Xrange(2) = Xrange(2) + floor((Xn-1)/2);
        end
    end
    
    if numel(var) < 4 || isempty(var{4}) %if XRange not specified
        Yrange=[min(D(:,2)),max(D(:,2))]; %default
    else
        if nnz(size(var{4})==[1 2]) ~= 2 %check is 1x2 array
            error 'YRange must be 1x2 array'
        end
        Yrange = var{4};
    end
    if Yrange(1)==Yrange(2) %handle case where YLO==YHI
        if Yndefault
            Yn = 1;
        else
            Yrange(1) = Yrange(1) - floor(Yn/2);
            Yrange(2) = Yrange(2) + floor((Yn-1)/2);
        end
    end
        
    % SET UP BINS
    Xlo = Xrange(1) ; Xhi = Xrange(2) ;
    Ylo = Yrange(1) ; Yhi = Yrange(2) ;
    if Xn == 1
        XnIs1 = true;
        Xbins = [Xlo Inf];
        Xn = 2;
    else
        XnIs1 = false;
        Xbins = linspace(Xlo,Xhi,Xn) ;
    end
    if Yn == 1
        YnIs1 = true;
        Ybins = [Ylo Inf];
        Yn = 2;
    else
        YnIs1 = false;
        Ybins = linspace(Ylo,Yhi,Yn) ;
    end
    
    Z = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);
    
    % split data
    Dx = floor((D(:,1)-Xlo)/(Xhi-Xlo)*(Xn-1))+1;
    Dy = floor((D(:,2)-Ylo)/(Yhi-Ylo)*(Yn-1))+1;
    Dz = Dx + Dy/(Yn) ;
    
    % calculate histogram
    h = reshape(histc(Dz, Z), Yn, Xn);
    
    if nargout >=1
        Hout = h;
    end
    
    if XnIs1
        Xn = 1;
        Xbins = Xbins(1);
        h = sum(h,1);
    end
    if YnIs1
        Yn = 1;
        Ybins = Ybins(1);
        h = sum(h,2);
    end
    
    % DISPLAY IF REQUESTED
    if ~display
        return
    end
        
    [x y] = meshgrid(Xbins,Ybins);
    dispH = h;

    % handle cases when Xn or Yn
    if Xn==1
        dispH = padarray(dispH,[1 0], 'pre');
        x = [x x];
        y = [y y];
    end
    if Yn==1
        dispH = padarray(dispH, [0 1], 'pre');
        x = [x;x];
        y = [y;y];
    end

    surf(x,y,dispH);
    colormap(jet);
    if Dcomplex
        xlabel real;
        ylabel imaginary;
    else
        xlabel x;
        ylabel y;
    end