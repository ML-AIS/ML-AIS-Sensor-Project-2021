% This script analyses and write outputs for Measurements.
% Program will act according to the following behaviours.
% 1. Read setting file and retrieve setting parameter
% 2. Look for data directories and read files in each folder.
% 3. Categorise data into category, which is pre-set by configuration file.
% 4. Create confusion matrix and calculate evaluation result.

%% 1. Read setting file and retrieve setting parameter
% This step will read setting file and retrieve parameters from it
setting_filename = 'setting.json';
fid = fopen(setting_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

setting = jsondecode(str);

exist_sheet_list = sheetnames(setting.Path.manage_filename);

if ~any(strcmp(setting.Sheet_mgn.main_sheet, exist_sheet_list))
    return;
end

% Filter sheet according to condition
% Possible cases
% 1. Header : true, false
% 2. Threshold : true, false

tbl_manage = readtable(setting.Path.manage_filename, ...
    'FileType', 'spreadsheet', ...
    'Sheet', setting.Sheet_mgn.main_sheet, ...
    'TextType', 'string', ...
    'ReadVariableNames', true);

%% 2. Look for data directories and read files in each folder.
data_sheet = setting.Sheet_mgn.read_sheet; % !TODO verify sheet before use.

% Process each loop per data sheet
for idx = 1:size(data_sheet, 1)
    
    % Read data table from sheet
    tbl_data = readtable(setting.Path.manage_filename, ...
        'FileType', 'spreadsheet', ...
        'Sheet', data_sheet{idx}, ...
        'TextType', 'string', ...
        'ReadVariableNames', true);
    
    % Filter data according to condition
    % Conditions
    % 1. Door_status: opened, closed
    % 2. Belt_status: belt, nobelt
    % 3. Movement_status: movement, nomovement
    
    % case_num = filter_file(setting.Filter_data);
    
    [list_filename, list_subject, list_measurement_amt] = filter_file(tbl_data, setting.Filter_data);
    
    list_filname = filter_file(tbl_data, setting.Filter_data);
    size_filelist = size(list_filname, 1);
    size_data = sum(list_measurement_amt, 1);
    
    class_real = strings(size_data, 1);
    class_pred = strings(size_data, 1);
    
    counter = 0;
    
    % Read each file
    for jdx = 1:size_filelist
        data_fullpath = fullfile(setting.Path.data_path, data_sheet{idx}, list_filname(jdx));
        content = readmatrix(data_fullpath);
        
        size_content = size(content, 1);
        %class_real = strings(size_content, 1);
        %class_pred = strings(size_content, 1);
        
        
        bgn_idx = (jdx-1)*size_content+1;
        end_idx = ((jdx-1)+1)*size_content;
        % Define real class array with class value
        if contains(list_subject(jdx), setting.Filter_data.target_class)
            class_real(bgn_idx: end_idx) = setting.Filter_data.target_class;
        elseif contains(list_subject(jdx), setting.Filter_data.nontarget_class)
            class_real(bgn_idx: end_idx) = setting.Filter_data.nontarget_class;
        else
            error("classification setting is wrong.");
        end
        
        % Guard for empty file --> skip file
        if isempty(content)
            continue;
        end
        
        % Guard for header in file --> skip file
        % headers have length in the first column
        check_headers = all(content(:,1) == setting.Filter_data.header_length);
        if ~(check_headers == true) % headers exist
            continue;
        end
        
        % Find class result in file
        class_pred(bgn_idx:end_idx, 1) = string(content(1:end, setting.Filter_data.classification_col));
        class_pred(class_pred=="1") = setting.Filter_data.nontarget_class; % !TODO make this more dynamic
        class_pred(class_pred=="2") = setting.Filter_data.nontarget_class; % !TODO make this more dynamic
        
    end
    
    
    
end


