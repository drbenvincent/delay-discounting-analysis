function handle = vline(x_val, varargin)
% Benjamin T. Vincent

handle.fig		= gcf;
handle.axis		= get(gcf,'CurrentAxes');

%% Draw the line
handle.line = line([x_val x_val], get(handle.axis,'Ylim'));

%% Create callbacks
handle.pan = pan(handle.fig);
handle.pan.ActionPostCallback = @callback_adjust_vline;

handle.zoom = zoom(handle.fig);
handle.zoom.ActionPostCallback = @callback_adjust_vline;

%% Formatting
set(handle.line, 'Color','r');
set(handle.line, 'LineStyle','-');
set(handle.line, 'LineWidth',0.5);

% Apply formatting provided
% NOTE: must store returned value to avoid its display to command window.
[~] = set(handle.line, varargin{:});

% send the line to the back
uistack(handle.line, 'bottom');

%% Callback

	function callback_adjust_vline(obj, event_obj)
		handle.line.YData = event_obj.Axes.YLim;
	end

end
