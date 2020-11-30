
%------------------------------------------------------------------------------
function phase_points = phase_accum(num_of_points, array_dimention, f_sampling,... 
                               freq_max_div, freq_max_mod)

    phase_points = ones(1, num_of_points, 'int32');
    accum = 0;
    freq_max_cnt = 0;
    
    code_length = 1023;
    init_reg = [0 0 0 0 0 0 1 0 0 1];
    [curr_discrete, reg] = (calc_discrete(init_reg));
    
    smpls_per_disc_div = floor(num_of_points/code_length);
    smpls_per_disc_mod = mod(num_of_points, code_length);
    smpls_per_disc_mod_cnt = smpls_per_disc_mod;
    disc_border_cnt        = smpls_per_disc_div;
    
    for step_num = 1:1:(num_of_points-1)
        
        [M, freq_max_cnt, smpls_per_disc_mod_cnt,... 
          disc_border_cnt, reg, curr_discrete] = step_coef(freq_max_cnt, freq_max_div, freq_max_mod,... 
                                                                  smpls_per_disc_mod_cnt, smpls_per_disc_div, smpls_per_disc_mod,... 
                                                                  array_dimention, code_length, f_sampling,step_num, ...
                                                                  disc_border_cnt, curr_discrete, reg);
        
        accum = bitand((accum + M), (array_dimention - 1));
        phase = bitand(floor(accum), (array_dimention - 1));
        phase_points(step_num + 1) = phase + 1;
    end

end

%------------------------------------------------------------------------------
function [M, freq_max_cnt, smpls_per_disc_mod_cnt,... 
          disc_border_cnt, reg, curr_discrete] = step_coef(freq_max_cnt, freq_max_div, freq_max_mod,... 
                                                                  smpls_per_disc_mod_cnt, smpls_per_disc_div, smpls_per_disc_mod,... 
                                                                  array_dimention, code_length, f_sampling,step_num, ...
                                                                  disc_border_cnt, curr_discrete, reg)
    M = freq_max_div;
    freq_max_cnt = freq_max_cnt + freq_max_mod;
    if (freq_max_cnt >= f_sampling)
        M = M + 1;
        freq_max_cnt = freq_max_cnt - f_sampling; 
    end
    
    if (step_num == disc_border_cnt)
        smpls_per_disc_mod_cnt = smpls_per_disc_mod_cnt + smpls_per_disc_mod;
        if (smpls_per_disc_mod_cnt >= code_length)
            smpls_per_disc_mod_cnt = smpls_per_disc_mod_cnt - code_length;
            disc_border_cnt   = disc_border_cnt + 1;
        end 
        disc_border_cnt = disc_border_cnt + smpls_per_disc_div;
        [next_discrete, reg] = (calc_discrete(reg));
        if (next_discrete ~= curr_discrete)
            M = M + array_dimention/2;
        end
        curr_discrete = next_discrete;
    end
end

%------------------------------------------------------------------------------
function [discrete, reg] = calc_discrete(reg)

    save_bit = xor(reg(7), reg(10));
%     save_bit = xor(reg(3), reg(5));
    reg(2:1:end) = reg(1:1:end-1);
    reg(1) = save_bit;
    discrete = reg(end);
    
end
%------------------------------------------------------------------------------
function discrete = calc_discrete_barker(i)
    
    barker = [1 1 1 1 1 0 0 1 1 0 1 0 1];
%     barker = [1 1 1 0 1];
    discrete = barker(i);
    
end
%------------------------------------------------------------------------------


