function cell_img = writeFFTImages(cell_datapath, read_datasheet, list_files, setting)

for idx = 1:size(cell_datapath, 1)

    % Write images into each folder according to sheetname
    img_path = read_datasheet{idx, 1};

    if ~isfolder(img_path) % images do not exists
        mkdir(img_path);
    end

    % remove file extension
    filename = replace(list_files{idx ,2}, ".txt", "");
    sub_folder = fullfile(img_path, filename);

    for kdx = 1:size(sub_folder, 1)
        if ~isfolder(sub_folder(kdx, 1))
            mkdir(sub_folder(kdx, 1));
        end
    end

    % Read Data and construct images
    for jdx = 1:size(cell_datapath{idx, 1}, 1)

        data = readmatrix(cell_datapath{idx, 1}(jdx, 1));

        % remove header if exists
        if setting.Sheet_mgn.sheet_headers{idx} == '1'
            data = data(:, 17:end);
        end

        cell_img = constructImg(data, setting.Img_data.img_height, ...
            setting.Img_data.input_min, ...
            setting.Img_data.input_max);
        
    end

end

% Write Image into each subfolder
for idx = 1:size(sub_folder, 1)
    total_img = size(cell_img, 1);

    disp("Begin writing file in folder "+sub_folder(idx, 1)+" ...");
    for ldx = 1:total_img
        img_filename = strcat("img_", num2str(ldx), setting.Img_data.img_extention);
        writepath = fullfile(sub_folder(idx, 1), img_filename);
        
        %imwrite(cell_img{ldx, 1}, writepath);

        % save images if not exist
        if isfile(writepath) % if exist, then skip
            continue
        else % writing images if not exist
            % convert to heatmap and save
            img = heatmap(cell_img{ldx});
            % Left out other metrics from image
            empty_strings = strings(1, 17);
            img.XDisplayLabels = empty_strings;
            empty_strings = strings(1, 5);
            img.YDisplayLabels = empty_strings;
            colorbar('off'); % Disable colorbar

            saveas(gcf, writepath);
        end
    end
    disp("Finished writing file in folder  "+sub_folder(idx, 1));
end

end

