function plotRawDataNOMAG(data)

x = data.D;
y = data.A ./ data.B;

% chose delayed
choseDel = data.R==1;
plot(x(choseDel),y(choseDel),'ko','MarkerFaceColor','k') % delayed
hold on
plot(x(~choseDel),y(~choseDel),'ko','MarkerFaceColor','w') % immediate

end