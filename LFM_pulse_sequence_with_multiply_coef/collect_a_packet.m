
%------------------------------------------------------------------------------


function packet = collect_a_packet(num_of_impulse, sin_points, num_of_zero_points, DAC_bit_resolution)
    
    packet = [];
    
    for i = 1:1:(num_of_impulse - 1)
        zero_points = int32((zeros(1, num_of_zero_points(i)) + 1)/2 * (2^DAC_bit_resolution - 1));
        packet = [packet, sin_points, zero_points];
    end
    
    packet = [packet, sin_points];

end
%------------------------------------------------------------------------------