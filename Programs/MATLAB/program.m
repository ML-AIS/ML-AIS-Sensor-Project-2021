% This script analyses and write outputs for Measurements.
% Program will act according to the following behaviours.
% 1. Read setting file and retrieve setting parameter
% 2. Look for data directories and read files in each folder.
% 3. Categorise data into category, which is pre-set by configuration file.
% 4. Classify data value and return classification result.
% 5. Create confusion matrix and calculate evaluation result.

%% 1. Read setting file and retrieve setting parameter
% This step will read setting file and retrieve parameters from it
setting_filename = 'setting.json';
fid = fopen(setting_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

setting = jsondecode(str);

exist_sheet_list = sheetnames(setting.Path.manage_filename);

if ~any(strcmp(setting.Sheet_mgn.main_sheet, exist_sheet_list))
    return;
end

% Filter sheet according to condition
% Possible cases
% 1. Header : true, false
% 2. Threshold : true, false

mgnment_file = fullfile( setting.Path.data_path   ,setting.Path.manage_filename);

tbl_manage = readtable(mgnment_file, ...
    'FileType', 'spreadsheet', ...
    'Sheet', setting.Sheet_mgn.main_sheet, ...
    'TextType', 'string', ...
    'ReadVariableNames', true);

%% 2. Look for data directories and read files in each folder.
read_data_sheet = setting.Sheet_mgn.read_sheet; % !TODO verify sheet before use.

% Verify if read sheets exist in management table or not
exist_data_sheet = tbl_manage.Measurement_date;
exist_data_sheet = exist_data_sheet(exist_data_sheet ~= setting.Filter_data.notexist); % clear empty value

verify_exist = contains(read_data_sheet, exist_data_sheet);
checktrue = all(verify_exist);

if ~checktrue
    error(["Read Sheets do not exist in management Sheet :", setting.Sheet_mgn.main_sheet]);
end

% Process each loop per data sheet
for idx = 1:size(read_data_sheet, 1)
    
    % Read data table from sheet
    tbl_data = readtable(setting.Path.manage_filename, ...
        'FileType', 'spreadsheet', ...
        'Sheet', read_data_sheet{idx}, ...
        'TextType', 'string', ...
        'ReadVariableNames', true);
    
    
    %% 3. Categorises data
    if (strcmp (setting.Sheet_mgn.sheet_threshold{idx}, 'true') ) % Threshold exist

        % Filter data according to condition
        list_filter = filter_file_thresh(tbl_data, setting.Filter_data);
        

    else % Threshold does not exist
        
        % Filter data according to condition
        [list_filename, ...
            list_subject, ...
            list_measurement_amt] = filter_file(tbl_data, setting.Filter_data);

    end
    
    %% 4. Classify data value and return classification result.
    [class_real, class_pred] = classify_data_thresh( ...
        read_data_sheet{idx}, ...
        list_filter, ...
        setting);
    
    
    %% 5. Create confusion matrix and evaluate data.
    % 0. Create evaluation table
    % 1. Read classification result 
    % 2. create confusion matrices and store in specified path
    % 3. write evaluation result to file.
    
    % 0. Create evaluation table
    col = size(setting.Output.table_entity, 1);
    row = size(class_real, 1);
    tbl_size = [row col];
    
    tbl_eval = table( ...
        'Size', tbl_size, ...
        'VariableNames', setting.Output.table_entity, ...
        'VariableTypes', setting.Output.table_entity_type ...
        );
    
    % 1. Read classification result 
    for kdx = 1:size(class_real, 1)
        class_real_res = categorical(class_real{kdx, 1});
        class_pred_res = categorical(class_pred{kdx, 1});
      
        % create dir if not exist
        sheet_folder = fullfile(confusion_matrix, read_data_sheet{idx});
        if ~exist(sheet_folder, 'dir')
            mkdir(sheet_folder);
        end
        
        % create confusion matrix
        plotconfusion(class_pred_res, class_real_res);
        
        % Save confusion matrix images
        % There are 2 cases (check with class_size)
        % 1.) Threshold exist
        % 2.) Threshold not exist
        if (size(class_real, 2) == 2) % Threshold exist
            X = class_real{kdx ,2}(1, 1); Y = class_real{kdx ,2}(1, 2);
            threshold_combi = strcat( X, '-', Y );
            save_cm_path = fullfile( setting.Output.conMat_path, threshold_combi, conf.output.conMat_filetype ) ;
            saveas(gcf, save_cm_path);
        else % Threshold not exist
            save_cm_path = fullfile( setting.Output.conMat_path, read_data_sheet{idx}, conf.output.conMat_filetype ) ;
            saveas(gcf, save_cm_path);
        end
        close(gcf);
                
        cm = confusionmat(class_pred_res, class_real_res);
        % Confusion Matrix
        % ref: https://en.wikipedia.org/wiki/Confusion_matrix
        % TP | FN
        % -------
        % FP | TN
        TP = cm(1); FN = cm(3); 
        FP = cm(2); TN = cm(4);
        
        P = TP+FN; PP = TP+FP;
        N = FP+TN; PN = FN+TN;
        
        % Evaluation result
        accuracy = (TP+TN)/(P+N);
        precision = TP/(TP+FP);
        recall= TP/P;
        f_score=2*TP/(2*TP+FP+FN);
        
        % Collect confusion matrix result
        % There are 2 cases
        % 1. Threshold exist
        % 2. Threshold not exist
        if (size(class_real, 2) == 2) % Threshold exist
            tbl_eval.X = X; tbl_eval.Y = Y; 
        else
            tbl_eval.X = '-'; tbl_eval.Y = '-'; 
        end
        
        % Evaluation result
        tbl_eval.Accuracy(kdx) = accuracy;
        tbl_eval.Precision(kdx) = precision;
        tbl_eval.Recall(kdx) = recall;
        tbl_eval.F1_Score(kdx) = f_score;
        
        % Confusion matrix result
        tbl_eval.TP(kdx) = TP; tbl_eval.FN(kdx) = FN;
        tbl_eval.FP(kdx) = FP; tbl_eval.TN(kdx) = TN;
        
    end
    
    disp(["Finished process on ",  read_data_sheet{idx}]);
    
    % Write Evaluation table
    eval_filename = fullfile('Evaluation Result', read_data_sheet{idx});
    writetable(tbl_eval, eval_filename);
    disp(["Finised writing result file: ", eval_filename]);
    
end

disp("End of Program!");


