function forceNonExponentialTick
set(gca, 'xticklabel', num2str(get(gca,'xtick')'))
set(gca, 'yticklabel', num2str(get(gca,'ytick')'))
return
