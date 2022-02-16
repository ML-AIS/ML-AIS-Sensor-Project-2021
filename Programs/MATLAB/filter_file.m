function list_filename = filter_file(tbl_data, filter_data)

filt_file   = ~contains(tbl_data.Filename, filter_data.nofileexist);
% Filter target class ( normally means human )
filt_door   = contains(tbl_data.Door_status, filter_data.door);
filt_target = contains(tbl_data.Subject, filter_data.target_class);
filt_belt   = contains(tbl_data.belt_status, filter_data.belt);
filt_mvment = contains(tbl_data.movement_status, filter_data.movement);

filter_target = filt_file.*filt_door.*filt_target.*filt_belt.*filt_mvment;
filter_target = logical(filter_target);
list_target = tbl_data.Filename(filter_target);

% Filter non_target class ( normally means empty)
filn_door   = contains(tbl_data.Door_status, filter_data.door);
filn_target = contains(tbl_data.Subject, filter_data.nontarget_class);

filter_nontarget = filt_file.*filn_door.*filn_target;
filter_nontarget = logical(filter_nontarget);
list_nontarget = tbl_data.Filename(filter_nontarget);

list_filename = strings(size(list_target, 1)+size(list_nontarget, 1), 1);
list_filename(1:size(list_nontarget, 1)) =  list_nontarget;
list_filename(size(list_nontarget,1)+1:end, 1) =  list_target;

end