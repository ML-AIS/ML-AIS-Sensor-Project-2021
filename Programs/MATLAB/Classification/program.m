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

mode = 0; % program mode 0: construct images 1: training and classify

% Read setting file
if (mode == 0)
    disp("Program begin with mode constructing images");
else
    disp("Program begin with mode training and classification");
end

setting_filename = "setting.json";
setting = readSetting(setting_filename);
disp(["Finished reading setting file from ", setting_filename]);

table_manage = readManagementFile(setting);
read_datasheet = setting.Sheet_mgn.read_sheet;
num_datasheet = size(read_datasheet, 1);
mgnment_file = fullfile( setting.Path.data_path ,setting.Path.manage_filename);

disp(["Finished reading management table from", setting.Path.manage_filename]);

if (mode == 0)
    %% 2. Filter expect files from criteria
    disp("Begin filtering expected files due to criteria");
    
    [list_files, cell_datapath] = listFilesFromCondition(num_datasheet, mgnment_file, read_datasheet, setting);

    %% 3. Construct FFT-Images from FFT-Data
    img_height = 5; input_min = 0; input_max = 1000;
    disp("Write Images into each subfolder ...");
    cell_img = writeFFTImages(cell_datapath, read_datasheet, list_files, setting);
    disp("Writing Image finished!");

elseif (mode == 1)
    %% 4. Feed FFT-Images into convNet and train network

    % Indicate Labels for classes
    imds = mappingLabels(read_datasheet, mgnment_file, setting);
    
    % Create CNN Network Layers
    img = imread(string(imds.Files(1)));
    input_size = size(img);

    % TODO modify Model to support data and improve results
    CNNlayers = createCNNlayers(input_size);

    % Train Network 
    train_test_ratio = 0.8;
    labelCount = countEachLabel(imds);
    [imdsTrain, imdsTest] = splitEachLabel(imds, train_test_ratio, 'randomize');
    
    options = trainingOptions('sgdm', ...
            'InitialLearnRate',0.1, ...
            'MaxEpochs',5, ...
            'MiniBatchSize',100, ...
            'Shuffle','every-epoch', ...
            'ValidationData',imdsTest, ...
            'ValidationFrequency',100, ...
            'Verbose',false, ...
            'ExecutionEnvironment','multi-gpu', ...
            'Plots','training-progress');

    disp("Train model ....");
    model = trainNetwork(imdsTrain,CNNlayers,options);

    %% 5. Classify FFT-Images
    %     disp("Classify network with Test Data ...");
    %     [YPred, score] = classify(model, imdsTest);
    %     YTest = imdsTest.Labels;

    %     plotconfusion(YTest,YPred);

end

