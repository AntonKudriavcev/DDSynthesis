%------------------------------------------------------------------------------

function avg_prob_density = convert_to_avg_prob_density(probability_density, step)

    avg_prob_density = zeros(1,(length(probability_density)/step));
    index = 1;
    
    for i = 1:step:length(probability_density)
        avg_prob_density(index) = sum(probability_density(i:i + step - 1)/step);
        index = index + 1;
    end
end

%------------------------------------------------------------------------------
