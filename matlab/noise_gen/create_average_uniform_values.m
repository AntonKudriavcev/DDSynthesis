%------------------------------------------------------------------------------

function rnd_values = create_average_uniform_values(minn, maxx, num_of_variables)

    m  = floor(log2(maxx));
    l = 731;
    u = 1;
    rnd_values = zeros(num_of_variables, 1);
    
    bit_depth = 40;
    z_curr = floor(2^(m - 2));
    
    mask = (2^m - 1);
    
    for i = 1:1:num_of_variables
        
        z_next = bitand((l * z_curr + u), (2^bit_depth - 1));
        shift_val = bitshift(z_next, -(bit_depth - m));
        buf = (bitand(shift_val, mask) + minn);
        
        rnd_values(i) = buf;
        z_curr = z_next;
        
    end 
end