% Program to classify data on ML-AIS project.
% -------------------------------------------------------------------------
% 1. Read the management file
% 2. Filter expect files from criteria
% 3. Construct FFT-Images from FFT-data
% 4. Feed FFT-Images into convNet
% 5. Label and Classify FFT-Images
% 6. Evaluation result
% -------------------------------------------------------------------------


%% 1. Read the Management File from directory

% Read setting file
disp("Program begin ...");

setting_filename = 'setting.json';
fid = fopen(setting_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

setting = jsondecode(str);
disp(["Finished reading setting file from ", setting_filename]);

read_datasheet = readMgnFile(setting);

disp(["Finish reading management table from", setting.Path.manage_filename]);

%% 2. Filter expect files from criteria
num_datasheet = size(read_datasheet, 1);
mgnment_file = fullfile( setting.Path.data_path ,setting.Path.manage_filename);

cell_tbl_data = cell(num_datasheet, 1);

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

    list_files{idx, 1} = read_datasheet{idx, 1};
    list_files(idx, 2:end) = listFiles(cell_tbl_data{idx}, setting.Filter_data);

    %% 3. Construct FFT-Images from FFT-Data
    img_height = 5;

    for jdx = 1:size(list_files{1, 2}, 1)

        % Construct fullfile path
        data_fullpath = fullfile(setting.Path.data_path, list_files{jdx, 1}, list_files{jdx, 2});
        
        % TODO throw data_fullpath into cell format
    end

end


% TODO Create another loop to read data
% Construct Image from data
data = readmatrix(data_fullpath());
img_cell = constructImg(data, img_height);

