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
    
    case_num = categorise_case(setting.Filter_data);
    
    filt_file   = ~contains(tbl_data.Filename, setting.Filter_data.nofileexist);
    filt_door   = contains(tbl_data.Door_status, setting.Filter_data.door);
    filt_target = contains(tbl_data.Subject, setting.Filter_data.target_class);
    filt_belt   = contains(tbl_data.belt_status, setting.Filter_data.belt);
    filt_mvment = contains(tbl_data.movement_status, setting.Filter_data.movement);
    
    filter = filt_file.*filt_door.*filt_target.*filt_belt.*filt_mvment;
    filter = logical(filter);
    
    filename_list = tbl_data.Filename(filter);
    
    
    
    
    
    switch case_num
        case 1
            
            
            
        case 2
            
        case 3
            
        case 4
            
        case 5
            
        case 6
            
        case 7
            
        case 8
            
        case 9
            
        case 10
            
        otherwise
            
    end
    
    
    
    
    
    
    
    tbl_data.Filename(  contains(tbl_data.Subject, setting.Filter_data.nontarget_class) );
    
    
    %     % List all data_path per sheet
    %     data_fullpath = fullfile(setting.Path.data_path, data_sheet{idx});
    %     list_datafile = dir(data_fullpath);
    %     list_datafile = list_datafile(3:end);
    %
    %     size_datafile = size(list_datafile, 1);
    %     list_datafullfile = strings(size_datafile, 1);
    %     for jdx = 1:size_datafile
    %         list_datafullfile(jdx) = fullfile(list_datafile(jdx).folder, list_datafile(jdx).name);
    %     end
    
    
    
    
    
    
    
    
    
end














tbl_data = readtable(setting.Path.manage_filename, ...
    'FileType', 'spreadsheet', ...
    'Sheet', read_sheet_list, ...
    'TextType', 'string', ...
    'ReadVariableNames', true);

unique_x = unique(tbl_data.X);
unique_y = unique(tbl_data.Y);

% Remove NaN value if exist (!TODO tmp soln)
unique_x = unique_x(1:end-1);
unique_y = unique_y(1:end-1);

size_x = size(unique_x, 1);
size_y = size(unique_y, 1);

thresh = zeros(size_x*size_y, 2);
% threshold value
% |  X  |   Y   |
% | 160 | 11000 |
% | 160 | 12000 |
% | 160 | 13000 |
% | ... | ...   |
% | N   | M     |

% Create threshold combination for x and y
counter = 1;
for i = 1:size_x
    for j = 1:size_y
        thresh(counter,1) = unique_x(i);
        thresh(counter,2) = unique_y(j);
        counter = counter + 1;
    end
end

% Create confusion matrix for each threshold combination\
% 1. Set condition for selection (all, header requirement, door_status, belt_status,
% movement_status, );
% 2.
combination_amount = size(thresh, 1);















