function apply_plot_function_to_subplot_handle(func, handle, plotdata)

if ~isa(func,'function_handle')
	return
end

subplot(handle)
func(plotdata);
end