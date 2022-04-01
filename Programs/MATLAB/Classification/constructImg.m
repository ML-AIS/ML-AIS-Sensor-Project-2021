function img_cell = constructImg(data, num_row, input_min, input_max)
% Construct images for data each row then return image cell.

data_row = size(data, 1);

% normalize data and multiply by 255 to get greyscale image
norm_data = rescale(data, 'InputMin', input_min,'InputMax', input_max);
img_data  = 255.*norm_data;

img_cell = cell(size(data, 1), 1);

frac = size(data, 2)/num_row;
img = zeros(num_row, frac);

% data in each row
for idx = 1:data_row

    % create image
    for jdx = 1:num_row

        beg_idx   = ((jdx-1)*frac+1);
        end_idx   = jdx*frac;

        img(jdx, 1:frac) = img_data(idx, beg_idx:end_idx);
        
    end

    img_cell{idx, 1} = img;
end


