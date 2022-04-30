% This program behaves as folloing
% 1. Create Image Data Store of Testing Data
% 2. Read CNN model into program
% 3. Classify each Image Data Store and return value
% 4. Generate result csv file

%% 1.
disp("Start Program");

disp("Load images into Image Data storage.");


% data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\Python\object_classification\object_classification\data\2022.03.04.2";
% label_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\2022.03.04.2\all_label.xls";


% data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\Python\object_classification\object_classification\data\2022.03.11";
% label_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\labels\2022.03.11_all_label.xls";


data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\Python\object_classification\object_classification\data\2022.04.14";
label_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\labels\2022.04.14_all_label.xls";



filetype = ".png";
% model_filename = 'cnn_model.mat';
% model_filename = 'cnn_model_2.mat';
% model_filename = 'cnn_model_3.mat';
% model_filename = 'cnn_model_4.mat';
% model_filename = 'cnn_model_5.mat';
model_filename = 'model/cnn_model_7.mat';


f = readmatrix(label_path);

% g = strings(size(f, 1), 1);
% 
% g(f==0) = "Empty";
% g(f==1) = "Human";


data_label = categorical(f);

imds = imageDatastore(data_path, ...
    'IncludeSubfolders', true, ...
    'FileExtensions', filetype);

% sore filenames naturally
N = natsortfiles(imds.Files);
imds.Files = N;

imds.Labels = data_label;





%% 2 Load model
disp("Load CNN Model ...");
model = load(model_filename,'-mat');
model = model.model;


%% 3 Classification
[YPred, scores] = classify(model, imds);

YTest = data_label;
plotconfusion(YTest,YPred);






