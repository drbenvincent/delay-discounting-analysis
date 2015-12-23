function triPlotSamples(X, PRIOR, labels, trueVals)
% Tri plot for grid approximation
% X has one column for each parameter, and one row for each sample. The value of X is the parameter value for the corresponding parameter.
%
% labels is cell array of parameter names

fprintf('triPlotSamples()... '), tic
%ND = ndims(X);
[COLS ND] = size(X);
ROWS = ND;
COLS = ND;

clf

for row = 1:ND
	for col = 1:ND

		if col>row
			%ax(row,col)=[];
			break
		end

		if col == row
			% draw histogram of dimension 'col'
			ax(row,col) = subplot(ROWS, COLS, sub2ind([COLS ROWS], col, row) );

			h(row,col) = histogram(X(:,col), 'EdgeColor','none',...
				'Normalization','pdf',...
				'FaceColor',[0.2 0.2 0.2]);
			axis tight, a=axis; ylim([0 a(4)]);
			a=axis;
			hold on
			% plot hist for prior
			histogram(PRIOR(:,col), 'EdgeColor','none',...
				'Normalization','pdf',...
				'FaceColor',[0.8 0.8 0.8]);
			axis(a);
			box off
			
			axis square

			% plot true value
			if ~isempty(trueVals)
				ylims=get(gca,'Ylim');
				line([trueVals(col) trueVals(col)], ylims,...
					'Color','k', 'LineStyle',':');
			end
		else
			% draw bivariate density of:
			% col, on x-axis
			% row, on y-axis
			ax(row,col) = subplot(ROWS, COLS, sub2ind([COLS ROWS], col, row) );
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%plot(X(:,col), X(:,row), '.')
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% scale VALUES so max value = 1
% 			VALUES = double(VALUES); VALUES = VALUES./max(VALUES);
% 			scatter(X(:,col), X(:,row), VALUES.*100, 'o');
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			h=histogram2(X(:,col), X(:,row),...
				'DisplayStyle','tile',...
				'ShowEmptyBins','on',...
				'EdgeColor','none');
			
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			axis xy
			axis square
			axis tight
			colormap(flipud(gray))

			% plot true value
			if numel(trueVals)>0
				ylims=get(gca,'Ylim');
				line([trueVals(col) trueVals(col)], ylims,...
					'Color','k', 'LineStyle',':');

				xlims=get(gca,'Xlim');
				line(xlims, [trueVals(row) trueVals(row)],...
					'Color','k', 'LineStyle',':');
			end

		end
	end

end

% add labels
for row = 1:ND
	for col = 1:ND
		if col>row, break, end

		subplot(ROWS, COLS, sub2ind([COLS ROWS], col, row) )

		% Y labels
		if col==1 && row>1
			%temp=set(ax(row,col));
			ylabel( labels{row} , 'Interpreter', 'latex')
		end

		% xlabels
		if row==ND && col<=ND
			%temp=set(ax(row,col));
			xlabel( labels{col} , 'Interpreter', 'latex')
		end
	end
end

% remove axis labels
for row = 1:ND
	for col = 1:ND
		if col>row, break, end

		% remove x ticks on all but bottom row
		%set(ax(row,col))
		%subplot(ROWS, COLS, sub2ind([COLS ROWS], col, row) )
		if row~=ND
			set(ax(row,col),'XTickLabels',[]);
		end

		% remove y ticks on all but 1st column
		%set(ax(row,col))
		%subplot(ROWS, COLS, sub2ind([COLS ROWS], col, row) )
		if col~=1 || ( col==1 && row==1)
			set(ax(row,col),'YTickLabels',[]);
		end
	end
end

% % % link x-axis values
% % for n=1:ND-1
% % 	linkaxes(ax([n:end],n), 'x');
% % end



% SORT POSITIONS
b=3;
figsize = 25;
siz = (figsize-(2*b))/ND;

for row = 1:ND
	for col = 1:ND
		if col>ND+1-row, break, end


		ax(ND+1-row,col).Units='centimeters';
		ax(ND+1-row,col).Position=[b+siz*(col-1)...
			b+siz*(row-1) siz siz];
	end
end

set(gcf,'Position',[600 0 700 700])

drawnow

toc

return
