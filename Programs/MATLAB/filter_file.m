function [list_filename, list_subject, list_measurement_amt] = filter_file(tbl_data, filter_data)

filt_file   = ~contains(tbl_data.Filename, filter_data.nofileexist);
%% Filter target class ( normally means human )
filt_door   = contains(tbl_data.Door_status, filter_data.door);
filt_target = contains(tbl_data.Subject, filter_data.target_class);
filt_belt   = contains(tbl_data.belt_status, filter_data.belt);
filt_mvment = contains(tbl_data.movement_status, filter_data.movement);

filter_target = filt_file.*filt_door.*filt_target.*filt_belt.*filt_mvment;
filter_target = logical(filter_target);
listfilename_target = tbl_data.Filename(filter_target);
listsubject_target = tbl_data.Subject(filter_target);
list_measurement_amt_target = tbl_data.Measurement_amount(filter_target);

%% Filter non_target class ( normally means empty)
filn_door   = contains(tbl_data.Door_status, filter_data.door);
filn_target = contains(tbl_data.Subject, filter_data.nontarget_class);

filter_nontarget = filt_file.*filn_door.*filn_target;
filter_nontarget = logical(filter_nontarget);
listfilename_nontarget = tbl_data.Filename(filter_nontarget);
listsubject_nontarget = tbl_data.Subject(filter_nontarget);
list_measurement_amt_nontarget = tbl_data.Measurement_amount(filter_nontarget);

%% Finalise list before return output
list_filename = strings(size(listfilename_target, 1)+size(listfilename_nontarget, 1), 1);
list_filename(1:size(listfilename_nontarget, 1)) =  listfilename_nontarget;
list_filename(size(listfilename_nontarget, 1)+1:end, 1) =  listfilename_target;

list_subject = strings(size(listsubject_target, 1)+size(listsubject_nontarget, 1), 1);
list_subject(1:size(listsubject_nontarget, 1)) = listsubject_nontarget;
list_subject(size(listsubject_nontarget, 1)+1:end, 1) = listsubject_target;

list_measurement_amt = zeros(size(list_measurement_amt_target, 1)+size(list_measurement_amt_nontarget, 1), 1);
list_measurement_amt(1:size(list_measurement_amt_nontarget, 1)) = list_measurement_amt_nontarget;
list_measurement_amt(size(list_measurement_amt_nontarget, 1)+1:end, 1) = list_measurement_amt_target;

end