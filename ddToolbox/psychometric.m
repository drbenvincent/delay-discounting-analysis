classdef psychometric
	%% psychometric: Short desctiption
	% Detailed exlanation here
	
	% public properties
	properties
		x
		y
		T % delays for each curve
		Ncurves
		C
		dataX			% delay
		dataY			% prob choose delayed
		saveDir
	end
	
	% read-only properties
	properties(GetAccess='public', SetAccess='private')
		figureHandle
		axisHandle
	end
	
	% protected, i.e. not visible from outside
	properties(Access = protected)
	end
	
	methods
		
		% Class constructor (same name as MYCLASS)
		function obj=psychometric(x,y, T)
			obj.x		= x;	
			obj.y		= y;
			obj.Ncurves	= size(y,2);
			obj.C		= ColorBand( obj.Ncurves );
			obj.T		= T;
			
			obj.saveDir ='figs';
		
			obj = obj.makeAxis();
			
			obj.plotTrueCurves()
			
		end
		
		function obj = makeAxis(obj)
			obj.figureHandle = figure(1);
			clf
			obj.axisHandle = gca;
			xlabel('value of delayed reward')
			ylabel('P(choose delayed)')
			title('Psychometric functions')
			hold on
			obj.axisHandle.YTick=[0:0.25:1];
		end
		
		function plotTrueCurves(obj)
			for n = 1:obj.Ncurves
				hPsycho(n) = plot(obj.x, obj.y(:,n),...
					'LineWidth',3, 'Color',obj.C(n,:));
			end
			legend(hPsycho,...
				{num2str(obj.T')},...
				'Location','SouthEast','FontSize',18)
			legend boxoff
		end
		
		function obj=addData(obj, x, N, trials)
			obj.dataX = x;
			for n = 1:obj.Ncurves
				obj.dataY(:,n) = N(:,n)./trials(n);
			end
			% plot
			obj.plotData()
		end
		
		function plotData(obj)
			hold on
			for n = 1:obj.Ncurves
				plot(obj.dataX, obj.dataY(:,n) ,...
					'.',...
					'MarkerSize',6^2,...
					'Color',obj.C(n,:))
			end
		end
		
		function export(obj, saveName)
			cd(obj.saveDir)
			latex_fig(12, 6,2)
			export_fig(saveName,'-png','-m3')
			hgsave(saveName)
			cd ..
			sprintf('Figure saved: %s', saveName);
		end
		
		
		function plotInferredCurves(obj, samples)
			figure(obj.figureHandle)
			for n = 1:numel(obj.T)
				decantedSamples = (samples(:,:,:,n));
				decantedSamples = reshape(decantedSamples,[2*5000,100]);
				psych(n).ci95 = prctile(decantedSamples,[5 95]);
			end
			for curve = 1:numel(obj.T)
				h(curve)=my_shaded_errorbar_zone_UL(obj.x,...
					psych(curve).ci95(2,:),...
					psych(curve).ci95(1,:),...
					obj.C(curve,:));
				h(curve).FaceAlpha = 0.2;
				h(curve).LineStyle = 'none';
			end
		end
		
	end % methods
	
end % classdef







%% Private functions 


