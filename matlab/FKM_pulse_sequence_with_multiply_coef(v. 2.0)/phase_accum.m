%------------------------------------------------------------------------------

function phase_points = phase_accum(num_of_points, array_dimention, freq_mult_coef, f_carrier, f_sampling)

    phase_points = ones(1, num_of_points, 'int32');
    accum = 0;
    
    M = floor(freq_mult_coef * array_dimention * f_carrier/f_sampling);
    
    code_len = 1023;
    init_reg = [0 0 0 0 0 0 1 0 0 1];
    [curr_discrete, reg] = (calc_discrete(init_reg)); % вычисление значения текущего дискрета
%     curr_discrete = calc_discrete_barker(1);
    discrete_num = 1;
    
    disc_mult_coef = 1024;
    samples_per_disc = floor((num_of_points * disc_mult_coef)/code_len); % вычисление количества отсчетов в одном дискрете
    
    discretes = [curr_discrete];
    
    for step_num = 1:1:(num_of_points - 1)
   
        num_of_curr_disc = floor((step_num * disc_mult_coef)/(samples_per_disc));
        
        if (num_of_curr_disc >= discrete_num)
            [next_discrete, reg] = calc_discrete(reg);
%             next_discrete = calc_discrete_barker(discrete_num + 1);
            if next_discrete ~= curr_discrete
                accum = bitand((accum + M + floor(array_dimention * freq_mult_coef/2)), (array_dimention * freq_mult_coef - 1));
            else
                accum = bitand((accum + M), (array_dimention * freq_mult_coef - 1));
            end
            curr_discrete = next_discrete;
            discrete_num = discrete_num + 1;
            
        else
            accum = bitand((accum + M), (array_dimention * freq_mult_coef - 1));
        end
        discretes = [discretes curr_discrete];
        phase = bitand(floor(accum/freq_mult_coef), (array_dimention - 1));
        phase_points(step_num + 1) = phase + 1;
    end
    
    % discretes = discretes-0.5;
    % figure(5);
    % plot(discretes);
    
    % figure(6);
    % acf = (xcorr(discretes));
    % acf = acf/max(acf);
    % plot(acf);
    
    
end

%------------------------------------------------------------------------------
function [discrete, reg] = calc_discrete(reg)

    save_bit = xor(reg(7), reg(10));
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
