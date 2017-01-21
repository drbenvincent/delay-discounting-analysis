function handle = hline(y_val, varargin)
% Benjamin T. Vincent

handle.fig		= gcf;
handle.axis		= get(gcf,'CurrentAxes');

%% Draw the line
handle.line = line(get(handle.axis,'Xlim'), [y_val y_val]);

%% Create callbacks
handle.pan = pan(handle.fig);
handle.pan.ActionPostCallback = @callback_adjust_hline;

handle.zoom = zoom(handle.fig);
handle.zoom.ActionPostCallback = @callback_adjust_hline;

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

	function callback_adjust_hline(obj, event_obj)
		handle.line.XData = event_obj.Axes.XLim;
	end

end
