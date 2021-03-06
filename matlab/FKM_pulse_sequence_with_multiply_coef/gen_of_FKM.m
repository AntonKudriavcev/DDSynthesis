%------------------------------------------------------------------------------

function sin_points = gen_of_FKM(num_of_sin_points, sin_points, DAC_bit_resolution)
    
    code_len = 1023;
    m_seq_phase = 1:1:num_of_sin_points;
    
    m_sequence = m_seq_gen(code_len);
    
    m_seq_phase = ceil(m_seq_phase/num_of_sin_points * code_len);
    
    m_sequence = m_sequence(m_seq_phase);
    
    for i = 1:1:num_of_sin_points
       if (m_sequence(i) == 0) 
           sin_points(i) = (2^DAC_bit_resolution - 1) - sin_points(i);
       end
    end
end

%------------------------------------------------------------------------------

function m_sequence = m_seq_gen(code_len)
    
    m_sequence = zeros(code_len);

    reg = [0 0 0 0 0 0 1 0 0 1];
    
    for i = 1:1:code_len
        
        save_bit = xor(reg(7), reg(10));
        reg(2:1:end) = reg(1:1:end-1);
        reg(1) = save_bit;
        m_sequence(i) = reg(end);
    end   
end