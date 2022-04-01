function table_manage = readManagementFile(setting)
% Read sheet according to setting and return expected to read data sheet list 

mgnment_file = fullfile( setting.Path.data_path ,setting.Path.manage_filename );
exist_sheet_list = sheetnames(mgnment_file);


if ~any(strcmp(setting.Sheet_mgn.main_sheet, exist_sheet_list))
    disp("Management sheet does not exist in sheet list");
    read_datasheet = "";
    return;
end

% Filter sheet according to condition
% Possible cases
% 1. Header : true, false
% 2. Threshold : true, false

table_manage = readtable(mgnment_file, ...
    'FileType', 'spreadsheet', ...
    'Sheet', setting.Sheet_mgn.main_sheet, ...
    'TextType', 'string', ...
    'ReadVariableNames', true);

% Look for data directories and read files in each folder.
read_datasheet = setting.Sheet_mgn.read_sheet; % !TODO verify sheet before use.

% Verify if read sheets exist in management table or not
exist_data_sheet = table_manage.Measurement_date;
exist_data_sheet = exist_data_sheet(exist_data_sheet ~= setting.Filter_data.notexist); % clear empty value

verify_exist = contains(read_datasheet, exist_data_sheet);
checktrue = all(verify_exist);

if ~checktrue
    error(["Read Sheets do not exist in management Sheet :", setting.Sheet_mgn.main_sheet]);
end

end