function apply_plot_function_to_subplot_handle(plotFunction, handle, plotdata)

if ~isa(plotFunction,'function_handle')
	return
end

subplot(handle)
plotFunction(plotdata);
end
