function [list_files, cell_datapath] = listFilesFromCondition(num_datasheet, mgnment_file, read_datasheet, setting)

cell_tbl_data = cell(num_datasheet, 1);
cell_datapath = cell(num_datasheet, 1);

for idx = 1:num_datasheet

    tbl_data = readtable(mgnment_file, ...
        'FileType', 'spreadsheet', ...
        'Sheet', read_datasheet{idx}, ...
        'TextType', 'string', ...
        'ReadVariableNames', true);

    cell_tbl_data{idx, 1} = tbl_data;

    % Read file criteria (Filter wanted files from list)

    % initialise list_files
    % list_files should look like this below diagram
    % | sheet_name  | list_filename   | list_subject   | list_data_amount |
    % | yyyy.mm.dd  | (M x 1 )        | (M x 1 )       | (M x 1 )         |
    % | yyyy.mm.dd  | (M x 1 )        | (M x 1 )       | (M x 1 )         |
    % | ...         |  ...            | ...            | ...              |
    amt_prop = 4;
    list_files = cell(num_datasheet, amt_prop);

    % List files from criteria
    list_files{idx, 1} = read_datasheet{idx, 1};
    list_files(idx, 2:end) = listFiles(cell_tbl_data{idx}, setting.Filter_data);

    % Construct full path for files
    size_listfile = size(list_files{1, 2}, 1);
    data_fullpath = strings(size_listfile, 1);
    for jdx = 1:size_listfile
        % Construct fullfile path
        data_fullpath(jdx, 1) = fullfile( setting.Path.data_path, list_files{idx, 1}, list_files{idx, 2}(jdx, 1) );
    end

    cell_datapath{idx, 1} = data_fullpath;
end

end