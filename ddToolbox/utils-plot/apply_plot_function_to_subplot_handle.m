function apply_plot_function_to_subplot_handle(func, handle, plotdata)
subplot(handle)
func(plotdata);
end