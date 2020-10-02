%------------------------------------------------------------------------------

function probability_interval_num = uniform_to_gauss_convertor(uniform_rnd_values, probability_density, num_of_simulation_points)

    probability_interval_num = zeros(num_of_simulation_points, 1);
    counter = 0;
    
    for i = 1:1:num_of_simulation_points
        for j = 1:1:length(probability_density)
            counter = counter + probability_density(j);
            if uniform_rnd_values(i) <= counter
                probability_interval_num(i) = j-1;
                counter = 0;
                break;
            end
        end
    end
end