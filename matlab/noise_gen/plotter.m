%------------------------------------------------------------------------------

function plotter(values_X, values_Y, label, figure_num)

    figure(figure_num);
    plot(values_X, values_Y);
    title(label)
    grid on;
end

%------------------------------------------------------------------------------
