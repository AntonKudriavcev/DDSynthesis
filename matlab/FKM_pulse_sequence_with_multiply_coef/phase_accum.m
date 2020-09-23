%------------------------------------------------------------------------------

function phase_points = phase_accum(num_of_points, array_dimention, mult_coef, f_carrier, f_sampling)

    phase_points = ones(1, num_of_points, 'int32');
    accum = 0;
    
    M = floor(mult_coef * array_dimention * f_carrier/f_sampling);
    
    for step_num = 1:1:(num_of_points - 1)
        accum = bitand((accum + M), (array_dimention * mult_coef - 1));
        phase = bitand(floor(accum/mult_coef), (array_dimention - 1));
        phase_points(step_num + 1) = phase + 1;
    end

end

%------------------------------------------------------------------------------