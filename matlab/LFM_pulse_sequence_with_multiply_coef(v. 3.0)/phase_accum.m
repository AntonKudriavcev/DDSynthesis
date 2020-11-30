
%------------------------------------------------------------------------------
function phase_points = phase_accum(num_of_points, array_dimention, f_sampling, t_disc, t_impulse,... 
                               freq_max_div, freq_max_mod, dlt_freq_div, dlt_freq_mod, dlt_step_denom)

    phase_points = ones(1, num_of_points, 'int32');
    accum = 0;
    freq_max_cnt = 0;
    dlt_freq_cnt = 0;
    bufferr      = 0;
    
    for step_num = 1:1:(num_of_points-1)
        
        [M, freq_max_cnt, dlt_freq_cnt, bufferr] = step_coef(freq_max_cnt, dlt_freq_cnt, bufferr, f_sampling, dlt_step_denom,...
                                                  freq_max_div, freq_max_mod, dlt_freq_mod, t_disc, t_impulse,...
                                                  step_num);
        
        accum = bitand((accum + M), (array_dimention - 1));
        phase = bitand(floor(accum), (array_dimention - 1));
        phase_points(step_num + 1) = phase + 1;
    end

end

%------------------------------------------------------------------------------
function [M, freq_max_cnt, dlt_freq_cnt, bufferr] = step_coef(freq_max_cnt, dlt_freq_cnt, bufferr, f_sampling, dlt_step_denom, ...
                                                   freq_max_div, freq_max_mod, dlt_freq_mod, t_disc, t_impulse, ...
                                                   step_num)
    
    M = freq_max_div;
    
    freq_max_cnt = freq_max_cnt + freq_max_mod;
    if (freq_max_cnt >= f_sampling)
        M = M + 1;
        freq_max_cnt = freq_max_cnt - f_sampling; 
    end

    if ((step_num * t_disc) < t_impulse/2)
        bufferr = bufferr + dlt_freq_mod;
        dlt_freq_cnt = dlt_freq_cnt + bufferr;
        
        if (dlt_freq_cnt >= 2 * dlt_step_denom)
            M = M - 2;
            dlt_freq_cnt = dlt_freq_cnt - 2 * dlt_step_denom;
        elseif (dlt_freq_cnt >= dlt_step_denom)
            M = M - 1;
            dlt_freq_cnt = dlt_freq_cnt - dlt_step_denom;    
        end
    else
        bufferr = bufferr - dlt_freq_mod;
        dlt_freq_cnt = dlt_freq_cnt + 2 * dlt_step_denom - bufferr;
        
        if (dlt_freq_cnt >= 2 * dlt_step_denom)
            dlt_freq_cnt = dlt_freq_cnt - 2 * dlt_step_denom;
        elseif (dlt_freq_cnt >= dlt_step_denom)
            M = M - 1;
            dlt_freq_cnt = dlt_freq_cnt - dlt_step_denom;
        else
            M = M - 2;
        end
    end
end
%------------------------------------------------------------------------------


