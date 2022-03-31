% Program to classify data on ML-AIS project.
% -------------------------------------------------------------------------
% 1. Read the management file
% 2. Filter expect files from criteria
% 3. Construct FFT-Images from FFT-data
% 4. Feed FFT-Images into convNet and train
% 5. Label and Classify FFT-Images
% 6. Evaluation result
% -------------------------------------------------------------------------


%% 1. Read the Management File from directory

mode = 1; % program mode 0: construct images 1: training and classify

% Read setting file
if (mode == 0)
    disp("Program begin with mode constructing images");
else
    disp("Program begin with mode training and classification");
end

setting_filename = 'setting.json';
fid = fopen(setting_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

setting = jsondecode(str);
disp(["Finished reading setting file from ", setting_filename]);


table_manage = readMgnFile(setting);
read_datasheet = setting.Sheet_mgn.read_sheet;
num_datasheet = size(read_datasheet, 1);
mgnment_file = fullfile( setting.Path.data_path ,setting.Path.manage_filename);

disp(["Finished reading management table from", setting.Path.manage_filename]);



if (mode == 0)
    %% 2. Filter expect files from criteria
    disp("Begin filtering expected files due to criteria");


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


    %% 3. Construct FFT-Images from FFT-Data
    img_height = 5; input_min = 0; input_max = 1000;
    for idx = 1:size(cell_datapath, 1)

        for jdx = 1:size(cell_datapath{idx, 1}, 1)

            data = readmatrix(cell_datapath{idx, 1}(jdx, 1));

            % remove header if exists
            if setting.Sheet_mgn.sheet_headers{idx} == '1'
                data = data(:, 17:end);
            end

            cell_img = constructImg(data, img_height, input_min, input_max);
        end

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

    end

    disp("Write Images into each subfolder ...");

    % Write Image into each subfolder
    for idx = 1:size(sub_folder, 1)

        total_img = size(cell_img, 1);
        for ldx = 1:total_img
            img_filename = strcat("img_", num2str(ldx), ".bmp");
            writepath = fullfile(sub_folder(idx, 1), img_filename);
            imwrite(cell_img{ldx, 1}, writepath);
        end
    end

    disp("Writing Image finished!");




elseif (mode == 1)
    %% 4. Feed FFT-Images into convNet and train network

    % Indicate Labels for classes
    for idx = 1:size(read_datasheet, 1)

        folder_name = read_datasheet{idx, 1};
        filetype = ".bmp";

        imds = imageDatastore(folder_name, ...
            'LabelSource', 'foldernames', ...
            'IncludeSubfolders', true, ...
            'FileExtensions', filetype);

        % TODO!
        % 1. Read data from each sheet
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
        for jdx = 1:total_img
            find_result = strcmp(string(imds.Labels(jdx)), tbl_mapping(:, 2));
            k = find(find_result);
            imds.Labels(jdx) = tbl_mapping(k, 1);
        end

    end
    
    % Create CNN Network Layers
    img = imread(string(imds.Files(1)));
    input_size = size(img);

    % TODO modify Model to support data
    % TODO why training shows 86 classes.
    
    CNNlayers = createCNNlayers(input_size);

    % Train Network 
    train_test_ratio = 0.8;
    labelCount = countEachLabel(imds);
    [imdsTrain, imdsTest] = splitEachLabel(imds, train_test_ratio, 'randomize');
    
    options = trainingOptions('sgdm', ...
            'InitialLearnRate',0.01, ...
            'MaxEpochs',30, ...
            'MiniBatchSize',16, ...
            'Shuffle','every-epoch', ...
            'ValidationData',imdsTest, ...
            'ValidationFrequency',30, ...
            'Verbose',false, ...
            'Plots','training-progress');

    disp("Train model ....");
    model = trainNetwork(imdsTrain,CNNlayers,options);


    %% 5. Classify FFT-Images
    disp("Classify network with Test Data ...");
    [YPred, score] = classify(model, imdsTest);
    YTest = imdsTest.Labels;

    plotconfusion(YTest,YPred);

end

