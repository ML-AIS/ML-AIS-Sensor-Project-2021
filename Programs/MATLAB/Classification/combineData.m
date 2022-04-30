% Program to combine all data into one file
config_filename = "config.json";
config = readSetting(config_filename);

data_path = config.data_path;
data_date = "2022.04.14";

load(strcat("list_files/", data_date, "_all_data.mat"));
data_filename = strcat("data/", data_date, "_all_data.xls");
label_filename = strcat("labels/", data_date, "_all_label.xls");

exp_sheet   =   list_files{1};
list_filenames = list_files{2};
list_subjects = list_files{3};
data_amt = list_files{4};

sum_data = sum(data_amt);

data_fullpath = fullfile(data_path, exp_sheet);

coln = 85;

all_data = zeros(sum_data, coln);
all_label = zeros(sum_data, 1);

% target = "Human";
nontarget = "Empty";

for idx = 1:size(list_filenames, 1)


    file_fullpath = fullfile(data_fullpath, list_filenames(idx, 1));

    data = readmatrix(file_fullpath);

    % determine whether data has header or not and extract only data
    [row, col]= size(data);
    if (col == config.data_size)
        data = data(2:end, :); % remove first row, since program will not detect headers
    else
        data = data(:, config.header_size+1:end);
    end
    
    % calculate index
    if (idx == 1)
        begin_row = 1;
        end_row = data_amt(idx);
    else
        begin_row = end_row + 1;
        end_row = begin_row + data_amt(idx) - 1;
    end
    
    all_data(begin_row:end_row, :) = data;
    
    if contains(list_subjects(idx), nontarget)
        all_label(begin_row:end_row, 1) = 0;
    else
        all_label(begin_row:end_row, 1) = 1;
    end

end


writematrix(all_data, data_filename);
writematrix(all_label, label_filename);