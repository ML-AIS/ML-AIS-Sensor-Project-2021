% Program to check and create Confusion Matrix
% 1. List file paths with keyword
% 2. Check if file has headers field
% 3. If so, check case and increment Confusion Matrix element


% Cases
% 1. Files with headers
% 2. Files without headers
TP = 0; FP = 0; TN = 0; FN = 0;

num_fileswithheaders = 0;
num_fileswithoutheaders = 0;
%% ---- Case for Confusion Matrix -----
% | TP | FP |
% | -- | -- |
% | FN | TN |
%
% 1. Empty Seat vs Human
%       TP : Empty --> Empty
%       FP : Not Empty --> Empty : Underestimation
%       FN : Empty --> Not Empty : Overestimation
%       TN : Not Empty --> Not Empty 

%% Read setting from json config file
configFilename = 'config.json';
fid = fopen(configFilename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

conf = jsondecode(str);

%% list path and prepare array for storing evaluation result

list_folder = dir(conf.input.data_path);
% Remove current and prev dir
list_folder = list_folder(3:end, :);

col = size(conf.setting.table_entity, 1);
row = size(list_folder, 1);
tbl_size = [row col];

% Create table for evaluation result

eval_tbl = table( ...
    'Size', tbl_size, ...
    'VariableNames', conf.setting.table_entity, ...
    'VariableTypes', conf.setting.table_entity_type ...
    );

disp("Program create confusion matrix beginn! ...");

for k = 1:tbl_size(1)
    
    path_fullfolder = fullfile(list_folder(k).folder, list_folder(k).name);
    path_withkey = fullfile(path_fullfolder, conf.input.search_keyword);
    % 1. List file paths with keyword
    listdir = dir(path_withkey);
    
    
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
                % 1. Empty target_group
                if contains(fullfilepath, conf.setting.target_group_keyword)
                    
                    result_actual(counter) = conf.setting.target_group;
                    
                    % Classification
                    % 1 : Empty
                    % 2 : Human
                    switch classification
                        case 1
                            result_classified(counter) = conf.setting.target_group;
                        case 2
                            % Empty -> Not Empty
                            result_classified(counter) = conf.setting.nontarget_group;
                        otherwise
                            disp(["Problem with Switch Case with ", conf.setting.target_group]);
                    end
                    
                    counter = counter + 1;
                    
                elseif contains(fullfilepath, conf.setting.nontarget_group_keyword)
                    
                    result_actual(counter) = conf.setting.nontarget_group;
                    
                    % Classification
                    % 1 : Empty
                    % 2 : Human
                    switch classification
                        case 1
                            % Not Empty -> Empty FP
                            result_classified(counter) = conf.setting.nontarget_group;
                        case 2
                            result_classified(counter) = conf.setting.target_group;
                        otherwise
                            disp("Problem with Switch Case ", conf.setting.nontarget_group);
                    end
                    
                    counter = counter + 1;
                    
                else
                    disp("This is a problem out of the ordinary");
                end
                
            end
            
        else % headers not exist
            num_fileswithoutheaders = num_fileswithoutheaders + 1;
            
        end
        
    end
    
    
    % Create Confusion Matrix
    % 1. Change array type from string array to categorical
    % 2. plot confusion Matrix
    % 3. Generate Images for confusion matrix
    result_actual = categorical(result_actual);
    result_classified = categorical(result_classified);
    
    plotconfusion(result_classified, result_actual);
    cm = confusionmat(result_classified, result_actual);
    
    % Confusion Matrix 
    % TP | FN
    % -------
    % FP | TN
    
    TP = cm(1); FN = cm(3);
    FP = cm(2); TN = cm(4);
    
    if ~exist(conf.output.conMat_path, 'dir')
        mkdir(conf.output.conMat_path)
    end    
    
    save_cm_path = fullfile( conf.output.conMat_path, strcat(list_folder(k).name, conf.output.conMat_filetype) );
    saveas(gcf, save_cm_path);
    
    accuracy = sum(result_classified == result_actual)/numel(result_actual);
    precision = TP/(TP+FP);
    recall= TP/(TP+FN);
    F_score=2*recall*precision/(precision+recall);
    
    % Evaluation
    eval_tbl.ThresholdSetting(k) = list_folder(k).name;
    eval_tbl.("Amount of Data")(k) = counter-1;
    eval_tbl.Accuracy(k) = accuracy;
    eval_tbl.Precision(k) = precision;
    eval_tbl.Recall(k) = recall;
    eval_tbl.("F1-Score")(k) = F_score;
    
    
    disp(["Finished process on ",  list_folder(k).name]);
    
end

writetable(eval_tbl, conf.output.evaluation_filename);
disp(["Finised writing result file: ", conf.output.evaluation_filename]);

disp("End of Program!");



