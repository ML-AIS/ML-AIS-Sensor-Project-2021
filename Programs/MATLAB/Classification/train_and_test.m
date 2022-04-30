% Train and Test

%folder_name = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\Python\object_classification\object_classification\data\2022.03.11";

base_data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\Python\object_classification\object_classification\data\";
%base_label_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\labels\";
base_label_path = "labels\";

data_path = dir(base_data_path);
label_path = dir(base_label_path);

% remove current and prev path
data_path = data_path(3:end);
label_path = label_path(3:end);

% remove last set of data for classification
data_path = data_path(1:end-1);
label_path = label_path(1:end-1);


if size(label_path) ~= size(data_path)
    error("Data size and label size are not equal.");
end

folder_name = strings(size(data_path));
labels = strings(size(label_path));



for i = 1:size(data_path)
    folder_fullpath = fullfile(data_path(i).folder, data_path(i).name);
    folder_name(i) = folder_fullpath;

    label_fullpath = fullfile(label_path(i).folder, label_path(i).name);
    labels(i) = label_fullpath;
    
end



% combine all labels
for i = 1:size(labels)
    f = readmatrix(labels(i));
    
    if i == 1
        end_index = size(f, 1);
        label_data(1:end_index, :) = f;
    else
        end_index = beg_index + size(f, 1) - 1;
        label_data(beg_index:end_index, :) = f;
    end

    beg_index = end_index + 1;
    
end

imds = imageDatastore(folder_name, ...
     'IncludeSubfolders', true, ...
     'FileExtensions', ".png");

% sore filenames naturally
N = natsortfiles(imds.Files);
imds.Files = N;

g = strings(size(label_data, 1), 1);

g(label_data==0) = "Empty";
g(label_data==1) = "Human";

imds.Labels = categorical(g);

% Create CNN Network Layers
img = imread(string(imds.Files(1)));
input_size = size(img);

% Create CNN Layers
CNNlayers = createCNNlayers(input_size);


% Train Network
train_test_ratio = 0.8;
labelCount = countEachLabel(imds);
[imdsTrain, imdsTest] = splitEachLabel(imds, train_test_ratio, 'randomize');

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',5, ...
    'MiniBatchSize',100, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsTest, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'ExecutionEnvironment','gpu', ...
    'Plots','training-progress');

disp("Train model ....");
model = trainNetwork(imdsTrain,CNNlayers,options);