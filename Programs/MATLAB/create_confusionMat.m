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
%path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-AIS-Sensor-Project-2021/Data/Sensor-1/";
% path of processed files with deleting first 10 rows of data
path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-AIS-Sensor-Project-2021/Data/Sensor-1/proc/";
keyword = "**/FFT_*.txt";


path_with_key = path+keyword;
% 1. List file paths with keyword
listdir = dir(path_with_key);

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
            % 1. Empty "E"
            if contains(fullfilepath, "FFT_E")
                
                switch classification
                    case 1
                        TP = TP + 1;
                    case 2
                        FN = FN + 1; % Empty -> Not Empty
                    otherwise
                        disp("Problem with Switch Case E condition");
                end
                
            elseif contains(fullfilepath, "FFT_H")
                
                switch classification
                    case 1
                        FP = FP + 1; % Not Empty -> Empty FP
                    case 2
                        TN = TN + 1;
                    otherwise
                        disp("Problem with Switch Case H condition");
                end
                
            else
                disp("Houstan, we have a big problem!!!");
            end
            
            
        end
        
    else % headers not exist
        num_fileswithoutheaders = num_fileswithoutheaders + 1;
        
    end
    
end


% Create Confusion Matrix
C = [TP FP; FN TN];
label = {'Empty Seat'; 'Human'};
cm = confusionchart(C, label);
cm.Title = 'Confusion Matrix of Empty Seat and Human Detection';


toc


