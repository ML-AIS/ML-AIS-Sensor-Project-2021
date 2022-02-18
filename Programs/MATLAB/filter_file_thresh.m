function list_filter = filter_file_thresh(tbl_data, filter_data)
% function [list_filename, list_subject, list_threshold, list_measurement_amt] = filter_file_thresh(tbl_data, filter_data)

filt_file   = ~contains(tbl_data.Filename, filter_data.notexist);

% Create combination of threshold X, Y
% list_threshold
% |   X    |   Y     |
% |  160   |  10000  |
% |  160   |  12000  |
% |  160   |  14000  |
% |  ...   |   ...   |
%list_threshold_x = tbl_data.X(1:filter_data.threshold_amt);

%TODO improvethis method.
% Condition if x or y change and must not duplicate with list
tmp_x = tbl_data.X(1:end);
tmp_y = tbl_data.Y(1:end);
counter = 1;
list_threshold_x = zeros(size(tmp_x, 1), 1);
list_threshold_y = zeros(size(tmp_x, 1), 1);

for j = 1:size(tmp_x, 1)
    
    if (j == 1)
        list_threshold_x(counter) = tmp_x(j);
        list_threshold_y(counter) = tmp_y(j);
        counter = counter + 1;
    else
        [lia_x, loc_x] = ismember(tmp_x(j), list_threshold_x);
        [lia_y, loc_y] = ismember(tmp_y(j), list_threshold_y);
        
        if ( lia_x && lia_y )
            % x at loc_y =? x  or y at loc_x =? y
            check_x = logical(tmp_x(j) == list_threshold_x(loc_y));
            check_y = logical(tmp_y(j) == list_threshold_y(loc_x));
            % check_xy = ismember([tmp_x(j) tmp_y(j)], [list_threshold_x list_threshold_y ]);
            if check_x && check_y
                continue;
            else
                list_threshold_x(counter) = tmp_x(j); list_threshold_y(counter) = tmp_y(j);
                counter = counter + 1;
            end
        elseif ( (tmp_x(j) ~= prev_x) && (tmp_y(j) == prev_y) ) % only x change
            list_threshold_x(counter) = tmp_x(j); list_threshold_y(counter) = tmp_y(j);
            counter = counter + 1;
        elseif ( (tmp_x(j) == prev_x) && (tmp_y(j) ~= prev_y) ) % only y change
            list_threshold_x(counter) = tmp_x(j); list_threshold_y(counter) = tmp_y(j);
            counter = counter + 1;
        elseif ( (tmp_x(j) ~= prev_x) && (tmp_y(j) ~= prev_y) )% both x and y change
            list_threshold_x(counter) = tmp_x(j); list_threshold_y(counter) = tmp_y(j);
            counter = counter + 1;
        else
            error("unexpected case with threshold");
        end
    end
    
    prev_x = tmp_x(j);
    prev_y = tmp_y(j);
end
% Remove zeros
list_threshold_x = list_threshold_x(list_threshold_x~=0);
list_threshold_y = list_threshold_y(list_threshold_y~=0);

% Remove NaN value from list
list_threshold_x = list_threshold_x(~isnan(list_threshold_x));
list_threshold_y = list_threshold_y(~isnan(list_threshold_y));

% Remove duplicates
list_threshold = [list_threshold_x, list_threshold_y];
tmp = list_threshold;
tmp = tmp';
tmp = unique(tmp.','rows').';
list_threshold = tmp';

% List_filter
% | list_filename  | list_subject   | list_data_amount | list_threshold   |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | {150 x 1 }     | {150 x 1 }     | {150 x 1 }       | {150 x 2 }       |
% | ...            | ...            | ...              | ...              |
list_filter = cell(size(list_threshold, 1), 4);

for i = 1:size(list_threshold, 1)
    
    %% Filter target class ( normally means human )
    filt_door   = contains(tbl_data.Door_status, filter_data.door);
    filt_target = contains(tbl_data.Subject, filter_data.target_class);
    filt_belt   = contains(tbl_data.belt_status, filter_data.belt);
    filt_mvment = contains(tbl_data.movement_status, filter_data.movement);
    
    % Filter threshold X and Y
    filt_thresh_x = ismember(tbl_data.X, list_threshold(i, 1));
    filt_thresh_y = ismember(tbl_data.Y, list_threshold(i, 2));
    
    % AND conditions
    filter_target = filt_file.* ...
        filt_door.* ...
        filt_target.* ...
        filt_belt.* ...
        filt_mvment.* ...
        filt_thresh_x.* ...
        filt_thresh_y;
    
    filter_target = logical(filter_target);
    
    listfilename_target = tbl_data.Filename(filter_target);
    listsubject_target = tbl_data.Subject(filter_target);
    list_measurement_amt_target = tbl_data.Measurement_amount(filter_target);
    list_threshold_target = [ tbl_data.X(filter_target), tbl_data.Y(filter_target) ];
    
    %% Filter non_target class ( normally means empty)
    filn_door   = contains(tbl_data.Door_status, filter_data.door);
    filn_nontarget = contains(tbl_data.Subject, filter_data.nontarget_class);
    
    % Filter threshold X and Y
    filn_thresh_x = ismember(tbl_data.X, list_threshold(i, 1));
    filn_thresh_y = ismember(tbl_data.Y, list_threshold(i, 2));
    
    filter_nontarget = filt_file.* ...
        filn_door.* ...
        filn_nontarget.* ...
        filn_thresh_x.* ...
        filn_thresh_y;
    
    filter_nontarget = logical(filter_nontarget);
    listfilename_nontarget = tbl_data.Filename(filter_nontarget);
    listsubject_nontarget = tbl_data.Subject(filter_nontarget);
    list_measurement_amt_nontarget = tbl_data.Measurement_amount(filter_nontarget);
    % list_threshold_nontarget = [ tbl_data.X(filter_nontarget), tbl_data.Y(filter_nontarget)];
    
    %% Finalise list before return output
    size_eachlist = size(filter_target(filter_target==1), 1) + size(filter_nontarget(filter_nontarget==1), 1);
    
    % list threshold
    list_threshold_exp = zeros(size_eachlist, 1);
    list_threshold_exp(1:end, 1) =  list_threshold_target(1, 1);
    list_threshold_exp(1:end, 2) =  list_threshold_target(1, 2);
    
    % list filename
    list_filename = strings(size_eachlist, 1);
    list_filename(1:size(listfilename_nontarget, 1)) =  listfilename_nontarget;
    list_filename(size(listfilename_nontarget, 1)+1:end, 1) =  listfilename_target;
    
    % list subject
    list_subject = strings(size_eachlist, 1);
    list_subject(1:size(listsubject_nontarget, 1)) = listsubject_nontarget;
    list_subject(size(listsubject_nontarget, 1)+1:end, 1) = listsubject_target;
    
    % list measurement amount
    list_measurement_amt = zeros(size_eachlist, 1);
    list_measurement_amt(1:size(list_measurement_amt_nontarget, 1)) = list_measurement_amt_nontarget;
    list_measurement_amt(size(list_measurement_amt_nontarget, 1)+1:end, 1) = list_measurement_amt_target;
    
    % Save each list to cell
    list_filter{i, 1} = list_filename;
    list_filter{i, 2} = list_subject;
    list_filter{i, 3} = list_measurement_amt;
    list_filter{i, 4} = list_threshold_exp;
    
end

end
