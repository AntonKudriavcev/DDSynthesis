%------------------------------------------------------------------------------

function expanded_values = expand_values(avg_gauss_values, step, num_of_simulation_points)

    m = floor(log2(step));
    l = 731;
    u = 1;

    bit_depth = 40;
    z_curr = floor(2^(m - 2));
    
    mask = (2^m - 1);

    expanded_values = zeros(num_of_simulation_points, 1);
    
    for i = 1:1:num_of_simulation_points
        
        z_next = bitand((l * z_curr + u), (2^bit_depth - 1));
        shift_val = bitshift(z_next, -(bit_depth - m));
        step_rnd_value = bitand(shift_val, mask);
        
        expanded_values(i) = step * avg_gauss_values(i) + step_rnd_value;
        z_curr = z_next;
        
    end
end