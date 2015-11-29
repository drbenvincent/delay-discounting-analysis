function [density,bx,by, modex, modey]=myHist2D(x,y , nxbins,nybins)
% Converts 2D scatter x,y data into a 2D grid image of density

if numel(nxbins)==1 && numel(nybins)==1
    % user provided the number of bins
    bx=linspace(min(x),max(x),nxbins);
    by=linspace(min(y),max(y),nybins);
else
    % user provided vectors
    bx=nxbins;
    by=nybins;
end

xbinhalfwidth=abs(bx(2)-bx(1));
ybinhalfwidth=abs(by(2)-by(1));

density=zeros(length(bx),length(by));

for cx=1:length(bx)
    
    for cy=1:length(by)
        
        SET = (x > (bx(cx)-xbinhalfwidth) & x < (bx(cx)+xbinhalfwidth))...
            & (y > (by(cy)-ybinhalfwidth) & y < (by(cy)+ybinhalfwidth));
        
        density(cx,cy)=sum(SET);
        
        clear SET
        
    end
end


h = imagesc(bx,by,density');
axis xy
colormap(gca, flipud(gray));

%h.colormap=(flipud(gray))


%% Calculate mode: simple method directly from histogram
[i,j]	= argmax2(density);
modex	= bx(i);
modey	= by(j);

end

% hold on
% 
% plot(x,y,'.','MarkerSize',1)
% hold off