
%------------------------------------------------------------------------------
function phase_points = phase_accum(num_of_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse)

    phase_points = ones(1, num_of_points, 'int32');
    accum = 0;
    
    for step_num = 1:1:(num_of_points-1)
        accum = bitand((accum + step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num)), (array_dimention*mult_coef - 1));
        phase = bitand(int64(accum/mult_coef), (array_dimention - 1));
        phase_points(step_num + 1) = phase + 1;
    end

end

%------------------------------------------------------------------------------
function M = step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num)
    if ((step_num * t_disc) < t_impulse/2)
        M = int64(mult_coef * (array_dimention/f_sampling) * (f_max - ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc)));
    else
        M = int64(mult_coef * (array_dimention/f_sampling) * (-(f_max - 2 * f_min) + ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc)));
    end
end
%------------------------------------------------------------------------------