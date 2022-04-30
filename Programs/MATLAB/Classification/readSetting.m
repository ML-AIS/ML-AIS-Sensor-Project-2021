function setting = readSetting(setting_filename)

fid = fopen(setting_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
setting = jsondecode(str);

end