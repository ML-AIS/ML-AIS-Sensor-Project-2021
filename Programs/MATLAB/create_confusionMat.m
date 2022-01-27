% Program to check and create Confusion Matrix
% 1. List file paths with keyword
% 2. Check if file has headers field
% 3. If so, check case and increment Confusion Matrix element


% Cases
% 1. Files with headers
% 2. Files without headers
tic
TP = 0; FP = 0; TN = 0; FN = 0;

num_fileswithheaders = 0;
num_fileswithoutheaders = 0;
%% ---- Case for Confusion Matrix -----
% | TN | FP |
% | -- | -- |
% | FN | TN |
%
% 1. Empty Seat vs Human
%       TP : Empty --> Empty
%       FP : Not Empty --> Empty : Underestimation
%       FN : Empty --> Not Empty : Overestimation
%       TN : Not Empty --> Not Empty

%%
% Keyword for search
% path of normal files
% path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-AIS-Sensor-Project-2021/Data/Sensor-1/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/160,12000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/160,14000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/160,16000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/160,20000/";
path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/180,10000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/180,12000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/180,14000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/200,10000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/200,12000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/200,14000/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold/250,15000/";


% path of processed files with deleting first 10 rows of data
% path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-AIS-Sensor-Project-2021/Data/Sensor-1/proc/";
% path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Data\Sensor-1_multiple_threshold_proc/";



keyword = "**/FFT_*.txt"; % change this keyword to filter files according to case.


path_with_key = path+keyword;
% 1. List file paths with keyword
listdir = dir(path_with_key);

% Declare array to contain actual result and classified results 
result_actual = strings(size(listdir, 1), 1);
result_classified = strings(size(result_actual, 1), 1);
counter = 1;

for index = 1:size(listdir)
    fullfilepath = fullfile(listdir(index).folder, listdir(index).name);
    
    % 2. Check if file has headers field
    content = readmatrix(fullfilepath);
    
    % guard for empty file
    if isempty(content)
        num_fileswithoutheaders = num_fileswithoutheaders + 1;
        continue;
    end
    
    
    checkones = all(content(:,1) == 64);
    
    % headers have 64 (bit length) in the first column
    if (checkones == true) % headers exist
        
        num_fileswithheaders = num_fileswithheaders + 1;
        
        % --------------------------------------
        % check classification result (column 3)
        % 1: object
        % 2: Human
        % --------------------------------------
        for jndex = 1:size(content, 1)
            classification = content(jndex, 3);
            
            
            % check keyword
            % 1. Empty "Empty Seat"
            if contains(fullfilepath, "FFT_E")
                
                result_actual(counter) = "Empty Seat";
                
                % Classification 
                % 1 : Empty
                % 2 : Human
                switch classification
                    case 1
                        TP = TP + 1;
                        result_classified(counter) = "Empty Seat";
                    case 2
                        FN = FN + 1; % Empty -> Not Empty
                        result_classified(counter) = "Human";
                    otherwise
                        disp("Problem with Switch Case E condition");
                end
                
                counter = counter + 1;
                
            elseif contains(fullfilepath, "FFT_H")
                
                result_actual(counter) = "Human";
                
                % Classification 
                % 1 : Empty
                % 2 : Human
                switch classification
                    case 1
                        FP = FP + 1; % Not Empty -> Empty FP
                        result_classified(counter) = "Empty Seat";
                    case 2
                        TN = TN + 1;
                        result_classified(counter) = "Human";
                    otherwise
                        disp("Problem with Switch Case H condition");
                end
                
                counter = counter + 1;
                
            else
                disp("This is a problem !!!");
            end
            
        end
        
    else % headers not exist
        num_fileswithoutheaders = num_fileswithoutheaders + 1;
        
    end
    
end


% Create Confusion Matrix
% 1. Change array type from string array to categorical
% 2. plot confusion Matrix
result_actual = categorical(result_actual);
result_classified = categorical(result_classified);

plotconfusion(result_classified, result_actual);

% Evaluation
accuracy = sum(result_classified == result_actual)/numel(result_actual);
precision = TP/(TP+FP);
recall= TP/(TP+FN);
F_score=2*recall*precision/(precision+recall);

disp("accuracy : " + accuracy);
disp("precision : " + precision);
disp("recall : " + recall);
disp("F_score : " + F_score);


toc


