function imds = mappingLabels(read_datasheet, mgnment_file, setting)

for idx = 1:size(read_datasheet, 1)

        folder_name = read_datasheet{idx, 1};

        imds = imageDatastore(folder_name, ...
            'LabelSource', 'foldernames', ...
            'IncludeSubfolders', true, ...
            'FileExtensions', setting.Img_data.img_extention);

        % Read data from each sheet
        tbl_data = readtable(mgnment_file, ...
            'FileType', 'spreadsheet', ...
            'Sheet', read_datasheet{idx}, ...
            'TextType', 'string', ...
            'ReadVariableNames', true);

        % remove extension from list filename
        list_filenames = tbl_data.Filename;
        list_filenames = strrep(list_filenames, ".txt", "");

        % remove number from target and non target subjects
        list_subjects = tbl_data.Subject;
        list_subjects(contains(list_subjects, setting.Filter_data.target_class)) = setting.Filter_data.target_class;
        list_subjects(contains(list_subjects, setting.Filter_data.nontarget_class)) = setting.Filter_data.nontarget_class;

        tbl_mapping = [list_subjects, list_filenames];
        
        % Mapping label according to class and filenames
        total_img = size(imds.Files, 1);
        list_labels = strings(total_img, 1);
        for jdx = 1:total_img
            find_result = strcmp(string(imds.Labels(jdx)), tbl_mapping(:, 2));
            k = find(find_result);
            list_labels(jdx, 1) = tbl_mapping(k, 1);
        end

        imds.Labels = categorical(list_labels);

end

end