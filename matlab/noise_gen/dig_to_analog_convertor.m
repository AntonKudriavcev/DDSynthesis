%------------------------------------------------------------------------------

function output_signal = dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, digital_values)

    output_signal = (digital_values/(2^DAC_bit_resolution - 1) * DAC_output_voltage) - (DAC_output_voltage/2);
    
end