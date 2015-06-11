function temp = normalisedNormpdf(x,params)

temp=normpdf(x,params(:,1),params(:,2)); 
temp=temp./sum(temp);
return

			