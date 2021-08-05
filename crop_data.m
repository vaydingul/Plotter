function data_cropped = crop_data(data)
%MEAN_UNEQUAL_LENGTH_DATA Summary of this function goes here
%   Detailed explanation goes here

length_array = cellfun(@length, data);
minimum_length = min(length_array);
data_cropped = cell2mat(cellfun(@(c) c(1:minimum_length), data, 'UniformOutput', false));

end

