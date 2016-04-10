classdef triPlotSamples < handle
	
	properties
		COLS
		ROWS
		ND
		ax
		borderSize
		figSize
		subplotSize % dependent?
		PRIOR
		POSTERIOR
		priorCol
		posteriorCol
		labels
		trueVals
	end
	
	methods
		
		function obj = triPlotSamples(PRIOR, POSTERIOR, labels, trueVals)
			if numel(PRIOR)>0
				assert( size(PRIOR,1)==size(POSTERIOR,1) )
				assert( size(PRIOR,2)==size(POSTERIOR,2) )
			end
			assert( size(POSTERIOR,2)==numel(labels) )
			
			[~, ND] = size(POSTERIOR);
			obj.ROWS = ND;
			obj.COLS = ND;
			obj.ND = ND;
			obj.PRIOR = PRIOR;
			obj.POSTERIOR = POSTERIOR;
			obj.labels = labels;
			obj.trueVals = trueVals;
			obj.borderSize = 2;
			obj.figSize = 25;
			obj.subplotSize  = (obj.figSize-(2*obj.borderSize))/obj.ND; % dependent?
			obj.posteriorCol = [0.2 0.2 0.2];
			obj.priorCol = [0.8 0.8 0.8];
			
			obj.plot()
			obj.addLabels()
			obj.removeAxisTickLabels()
			obj.subplotPositioning()
			
			set(gcf,...
				'Units', 'centimeters',...
				'Position',[1 1 obj.figSize obj.figSize])
			drawnow
		end
		
		function plot(obj)
			for row = 1:obj.ND
				for col = 1:obj.ND
					if col>row
						% upper triangle is empty
						break
					elseif col == row
						obj.drawHist(row, col)
					else
						obj.drawBivariateDensity(row, col)
					end
				end
			end
		end
		
		function drawHist(obj, row, col)
			% draw histogram of dimension 'col'
			obj.ax(row,col) = subplot(obj.ROWS, obj.COLS, sub2ind([obj.COLS obj.ROWS], col, row) );
			
			h(row,col) = histogram(obj.POSTERIOR(:,col),...
				'EdgeColor','none',...
				'Normalization','pdf',...
				'FaceColor',obj.posteriorCol);
			axis tight, a=axis; ylim([0 a(4)]);
			a=axis;
			if ~isempty(obj.PRIOR)
				hold on
				histogram(obj.PRIOR(:,col),...
					'EdgeColor','none',...
					'Normalization','pdf',...
					'FaceColor',obj.priorCol);
				axis(a);
			end
			box off
			
			axis square
			
			showHDI(obj.POSTERIOR(:,col))
			
			obj.plotUnivariateTrueValue()
		end
		
		
		function drawBivariateDensity(obj, row, col)
			% draw bivariate density of:
			% col, on x-axis
			% row, on y-axis
			obj.ax(row,col) = subplot(obj.ROWS, obj.COLS, sub2ind([obj.COLS obj.ROWS], col, row) );
			
			h = histogram2(obj.POSTERIOR(:,col), obj.POSTERIOR(:,row),...
				'DisplayStyle','tile',...
				'ShowEmptyBins','on',...
				'EdgeColor','none');
						
			axis xy
			axis square
			axis tight
			colormap(flipud(gray))
			
			obj.plotBivariateTrueValues()
		end
		
		function addLabels(obj)
			for row = 1:obj.ND
				for col = 1:obj.ND
					
					if col>row, break, end
					
					subplot(obj.ROWS, obj.COLS, sub2ind([obj.COLS obj.ROWS], col, row) )
					if obj.shouldAddYLabel(row,col)
						ylabel( obj.labels{row} , 'Interpreter', 'latex')
					end
					
					if obj.shouldAddXLabel(row, col)
						xlabel( obj.labels{col} , 'Interpreter', 'latex')
					end
					
				end
			end
		end
		
		
		function removeAxisTickLabels(obj)
			for row = 1:obj.ND
				for col = 1:obj.ND
					
					if col>row, break, end
					
					% remove x ticks on all but bottom row
					if row~=obj.ND
						set(obj.ax(row,col),'XTickLabels',[]);
					end
					
					% remove y ticks on all but 1st column
					if obj.shouldRemoveYTicks(row,col)
						set(obj.ax(row,col),'YTickLabels',[]);
					end
				end
			end
		end
		
		function subplotPositioning(obj)
			for row = 1:obj.ND
				for col = 1:obj.ND
					if col>obj.ND+1-row, break, end % TODO: simplify conditional, or replace with method
					set(obj.ax(obj.ND+1-row,col),...
						'Units','centimeters')
					set(obj.ax(obj.ND+1-row,col),...
						'Position', obj.calcPositionVector(row,col))
				end
			end
		end
		
		function pos = calcPositionVector(obj, row, col)
				pos = [obj.borderSize + obj.subplotSize*(col-1)...
					obj.borderSize + obj.subplotSize*(row-1)...
					obj.subplotSize...
					obj.subplotSize];
		end
		
		function plotUnivariateTrueValue(obj)
			if ~isempty(obj.trueVals)
				ylims=get(gca,'Ylim');
				line([obj.trueVals(col) obj.trueVals(col)], ylims,...
					'Color','k', 'LineStyle',':');
			end
		end
		
		function plotBivariateTrueValues(obj)
			if numel(obj.trueVals)>0
				ylims=get(gca,'Ylim');
				line([obj.trueVals(col) obj.trueVals(col)], ylims,...
					'Color','k', 'LineStyle',':');
				xlims=get(gca,'Xlim');
				line(xlims, [obj.trueVals(row) obj.trueVals(row)],...
					'Color','k', 'LineStyle',':');
			end
		end
		
		function bool = shouldAddXLabel(obj, row,col)
			bool = row==obj.ND && col<=obj.ND;
		end
		
	end
	
	methods (Static)
		
		function bool = shouldRemoveYTicks(row,col)
			bool = col~=1 || ( col==1 && row==1);
		end
		
		function bool = shouldAddYLabel(row,col)
			bool = col==1 && row>1;
		end

	end
	
end
