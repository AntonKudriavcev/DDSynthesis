
%------------------------------------------------------------------------------

function packet = collect_a_packet(num_of_impulse, sin_points, zero_points)
    
    packet = [];
    
    for i = 1:1:(num_of_impulse-1)
        packet = [packet, sin_points, zero_points];
    end
    
    packet = [packet, sin_points];

end
%------------------------------------------------------------------------------