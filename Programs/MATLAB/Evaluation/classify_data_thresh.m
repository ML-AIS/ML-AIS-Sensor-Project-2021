function [class_real, class_pred] = classify_data_thresh(data_sheet, list_filter, setting, index)

size_list_filter = size(list_filter, 1);

data_path = setting.Path.data_path;
filter_data = setting.Filter_data;

% classfication cell structure
% | 1st-col             | 2nd-col   |
% | {classified result} | threshold |
% | {classified result} | threshold |

if( strcmp(setting.Sheet_mgn.sheet_threshold(index), 'true') ) % Threshold exist
    class_real = cell(size_list_filter, 2);
    class_pred = cell(size_list_filter, 2);
else % Threshold not exist
    class_real = cell(size_list_filter, 1);
    class_pred = cell(size_list_filter, 1);
end

% Read each file
% 2 cases
% 1. Threshold exist
% list_filter
% | list_filename  | list_subject   | list_data_amount | list_threshold   |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | ...            | ...            | ...              | ...              |

% 2. Threshold not exist (cell has only 1x3 size)
% | list_filename  | list_subject   | list_data_amount |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       |

for idx = 1:size_list_filter
    
    % filename
    size_list_filename = size(list_filter{idx, 1}, 1);
    
    % measurement_amount
    size_data = sum(list_filter{idx, 3});
    
    class_real_each = strings(size_data, 1);
    class_pred_each = strings(size_data, 1);
    
    % Case : Empty list, cannot find matched cases
    if strcmp(list_filter{idx}, setting.Filter_data.notexist)
        class_real{idx, 1} = setting.Filter_data.notexist;
        class_pred{idx, 1} = setting.Filter_data.notexist;
        
        class_real{idx, 2} = setting.Filter_data.notexist;
        class_pred{idx, 2} = setting.Filter_data.notexist;
        continue;
    end
    
    
    
    for jdx = 1:size_list_filename
        
        data_fullpath = fullfile(data_path, data_sheet, list_filter{idx}(jdx));
        content = readmatrix(data_fullpath);
        
        size_content = size(content, 1);
        
        % Index of classification result
        if (jdx == 1)
            bgn_idx = ((jdx-1)*size_content)+1;
            end_idx = ((jdx-1)+1)*size_content;
        else
            bgn_idx = end_idx+1;
            end_idx = bgn_idx+size_content-1;
        end
        
        % Define real class array with class value
        % list_filter(x, 2) = subject
        if contains(list_filter{idx, 2}(jdx), filter_data.target_class)
            class_real_each(bgn_idx: end_idx) = filter_data.target_class;
        elseif contains(list_filter{idx, 2}(jdx), filter_data.nontarget_class)
            class_real_each(bgn_idx: end_idx) = filter_data.nontarget_class;
        else
            error("classification setting is wrong.");
        end
        
        % Guard for empty file --> skip file
        if isempty(content)
            continue;
        end
        
        % Guard for header in file --> skip file
        % headers have length in the first column
        check_headers = all(content(:,1) == filter_data.header_length);
        if ~(check_headers == true) % headers exist
            continue;
        end
        
        % Find class result in file
        class_pred_each(bgn_idx:end_idx, 1) = string(content(1:end, filter_data.classification_col));
        class_pred_each(class_pred_each==filter_data.nontarget_index) = filter_data.nontarget_class;
        class_pred_each(class_pred_each==filter_data.target_index) = filter_data.target_class;
        
    end
    
    class_real{idx, 1} = class_real_each;
    class_pred{idx, 1} = class_pred_each;
    
      % Check if lsit_filter has threshold data or not
    if size(list_filter, 2) == 4
        class_real{idx, 2} = list_filter{ idx,4 };
        class_pred{idx, 2} = list_filter{ idx,4 };
    end
    
end

end