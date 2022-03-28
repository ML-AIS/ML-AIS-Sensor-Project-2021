function list_files = listFiles(tbl_data, filter)

% mockup return data structure
amt_prop = 3;
list_files = cell(1, amt_prop);

% filter out non-existed file
exist_files = ~contains(tbl_data.Filename, filter.notexist);

% Target class filter
tar_door        = contains(tbl_data.Door_status, filter.door);
tar_target      = contains(tbl_data.Subject, filter.target_class);
tar_belt        = contains(tbl_data.belt_status, filter.belt);
tar_mvment      = contains(tbl_data.movement_status, filter.movement);
tar_distance    = contains(tbl_data.Distance, filter.Distance);
tar_dress       = contains(tbl_data.Dress_variation, filter.Dress_variation);

% AND conditions
target_files = exist_files & ...
    tar_door & ...
    tar_target & ...
    tar_belt & ...
    tar_mvment & ...
    tar_distance & ...
    tar_dress;

target_files = logical(target_files);

% Non-target class fitler
non_door    = contains(tbl_data.Door_status, filter.door);
non_target  = contains(tbl_data.Subject, filter.nontarget_class);

% AND conditions
nontarget_files = exist_files & non_door & non_target;

nontarget_files = logical(nontarget_files);

% OR operation between target and non-target files
exp_files = target_files | nontarget_files;

% Return value
% | list_filename   | list_subject   | list_data_amount |
list_files{1, 1} = tbl_data.Filename(exp_files);
list_files{1, 2} = tbl_data.Subject(exp_files);
list_files{1, 3} = tbl_data.Measurement_amount(exp_files);

end