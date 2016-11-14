function h = vline(x_val, varargin)
% Benjamin T. Vincent

h.fig		= gcf;
h.axis		= get(gcf,'CurrentAxes');

%% Draw the line
h.line = line([x_val x_val], get(h.axis,'Ylim'));

%% Create callbacks
h.pan = pan(h.fig);
h.pan.ActionPostCallback = @callback_adjust_hline;

h.zoom = zoom(h.fig);
h.zoom.ActionPostCallback = @callback_adjust_hline;

%% Formatting
set(h.line, 'Color','r');
set(h.line, 'LineStyle','-');
set(h.line, 'LineWidth',0.5);

% Apply formatting provided
% NOTE: must store returned output, otherwise it's outputted to the command
% window.
temp = set(h.line, varargin{:});

% send the line to the back
uistack(h.line, 'bottom');

%% Callback

	function callback_adjust_hline(obj, event_obj)
		h.line.YData = event_obj.Axes.YLim;
	end

end
