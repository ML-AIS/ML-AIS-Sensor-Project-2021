% Program to list filenames on ML-AIS project.
% -------------------------------------------------------------------------
% 1. Read the management file
% 2. Return list of target as output
% -------------------------------------------------------------------------

%% 1.   Read the Management File from directory

config_filename = "config.json";
config = readSetting(config_filename);

managefile_fullpath = fullfile(config.data_path, config.management_filename);
list_sheets = sheetnames(managefile_fullpath);

read_sheet = "2022.04.14";
save_filename = "list_files/2022.04.14_all_data.mat";

% Check if read_sheet exists in list_sheets or not
if ~ismember(read_sheet, list_sheets)
    error("Sheet does not exist in list.");
end

%% 2.   Return list of target as output
%   2.1 output
%       > list of filenames
%       > list of subjects
%       > list of data amount
%   2.2 requirements
%       > check if header exists
%       > check data amount
%       > check outliers 
%           > gives output filename for outliers
%           > resolves outliers with remove rows and re-indexing label

tbl_data = readtable(managefile_fullpath, ...
    "FileType","spreadsheet", ...
    "Sheet",read_sheet);

list_filenames  = tbl_data.Filename;
list_subjects   = tbl_data.Subject;


% remove nonexist files from list
file_exists = (list_filenames~="-") & ~isnan(tbl_data.Order);

list_filenames = list_filenames(file_exists);
list_subjects = list_subjects(file_exists); 
list_dataamount = zeros(size(list_filenames, 1), 1);

list_outliers = zeros(size(list_filenames, 1), 1);

% Find data amount and ouliers
for i = 1:size(list_filenames, 1)
    file_fullpath = fullfile(config.data_path, read_sheet, list_filenames(i));
    data = readmatrix(file_fullpath);

    % determine whether data has header or not and extract only data
    [row, col]= size(data);
    if (col == config.data_size)
        data = data(2:end, :); % remove first row, since program will not detect headers
    else
        data = data(:, config.header_size+1:end);
    end

    % determine if data has outliers
    % check fft value max and min
    if max(max(data)) > config.fft.upper_limit
        list_outliers(i) = 1;
    elseif min(min(data)) < config.fft.lower_limit
        list_outliers(i) = 1;
    end
    
    list_dataamount(i) = size(data, 1); % count rows 
end

% remove list_outliers
list_filenames = list_filenames(list_outliers==0);
list_subjects = list_subjects(list_outliers==0);
list_dataamount = list_dataamount(list_outliers==0);

list_files = {read_sheet, list_filenames, list_subjects, list_dataamount};
save(save_filename, "list_files");
















