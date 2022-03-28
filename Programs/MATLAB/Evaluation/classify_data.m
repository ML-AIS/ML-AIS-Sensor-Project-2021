function [class_real, class_pred] = classify_data(data_sheet, lst_filename, lst_subj,lst_mgnment_amt, filter_data)

% list_filname = filter_file(tbl_data, filter_data);
size_filelist = size(lst_filename, 1);
size_data = sum(lst_mgnment_amt, 1);

class_real = strings(size_data, 1);
class_pred = strings(size_data, 1);

% Read each file
for jdx = 1:size_filelist
    data_fullpath = fullfile(setting.Path.data_path, data_sheet, lst_filename(jdx));
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
    if contains(lst_subj(jdx), filter_data.target_class)
        class_real(bgn_idx: end_idx) = filter_data.target_class;
    elseif contains(lst_subj(jdx), filter_data.nontarget_class)
        class_real(bgn_idx: end_idx) = filter_data.nontarget_class;
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
    class_pred(bgn_idx:end_idx, 1) = string(content(1:end, filter_data.classification_col));
    class_pred(class_pred==filter_data.nontarget_index) = filter_data.nontarget_class;
    class_pred(class_pred==filter_data.target_index) = filter_data.target_class;
end

end