%------------------------------------------------------------------------------

function output_signal = output_signal_conv(input_array, DAC_bit_resolution, DAC_output_voltage)

    output_signal = ((input_array/(2^DAC_bit_resolution - 1))-0.5) * DAC_output_voltage;

end