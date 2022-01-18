% Program to truncate row data inside files
% 1.) list files in path, also in subfolders according to keyword
% 2.) open each file and delete first 10 rows 
% 3.) write new file with new folder name


input_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1\";
output_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1\proc\";

keyword = "**/FFT_*.txt";
del_row = 10;

path_with_key = input_path+keyword;
% 1. List file paths with keyword
listdir = dir(path_with_key);

for index = 1:size(listdir)
    fullfilepath = fullfile(listdir(index).folder, listdir(index).name);
    
    % 2. open file and delete ten first rows
    content = readmatrix(fullfilepath);
    
    content_new = content(del_row+1:end,:);
    
    % 3 write new file with new path 
    % extract only folder name
    folder_name = replace(listdir(index).folder, input_path , "");
    
    
    output_folder = fullfile(output_path, folder_name);
    output_fullfilepath = fullfile(output_path, folder_name, listdir(index).name);
    
    % check if there is directory, if not create one
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    
    
    writematrix(content_new, output_fullfilepath);
    
end

