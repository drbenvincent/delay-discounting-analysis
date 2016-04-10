function plotMCclusters(mcmc, data, col, probMass)
  display('** WARNING ** Making this plot takes time...')
  % plot posteriors over (m,c) for all participants, as contour
  % plots
  figure(12)
  % participants
  for p = 1:data.nParticipants
    [samples] = mcmc.getSamplesAtIndex(p, {'m','c'});
    [bi] = plot2DmcContour(...
      samples.m,...
      samples.c,...
      probMass,...
      definePlotOptions4Participant(col));
    % plot numbers
    text(bi.modex,bi.modey,...
      sprintf('%d',p),...
      'HorizontalAlignment','center',...
      'VerticalAlignment','middle',...
      'FontSize',9,...
      'Color',col)
    drawnow
  end
  % group
  plot2DmcContour(...
    mcmc.getSamplesAsMatrix({'m_group'}),...
    mcmc.getSamplesAsMatrix({'c_group'}),...
    probMass,...
    definePlotOptions4Group(col));

  axis tight
  set(gca,'XAxisLocation','origin')
  set(gca,'YAxisLocation','origin')
  drawnow

  function plotOpts = definePlotOptions4Participant(col)
    plotOpts.FaceAlpha = '0.1';
    plotOpts.FaceColor = col;
    plotOpts.LineStyle = 'none';
  end

  function plotOpts = definePlotOptions4Group(col)
    plotOpts.FaceColor = 'none';
    plotOpts.EdgeColor = col;
    plotOpts.LineWidth = 2;
  end
end
