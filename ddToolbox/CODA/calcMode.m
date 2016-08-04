function mode = calcMode(x)
[F, XI] = ksdensity( x );
[~, ind] = max(F);
mode = XI(ind);
end