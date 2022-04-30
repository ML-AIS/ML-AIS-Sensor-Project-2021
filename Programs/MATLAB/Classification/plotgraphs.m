% data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\2022.03.04.2\all_data.xls";
% data_label = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\2022.03.11\all_label.xls";
data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\2022.03.11\all_data.xls";

% data_path = "all_empty_data.xls";

x = 1:85;

data = readmatrix(data_path);

% data = data(1:15000, :);

figure(10)
plot(x, data(18001:18400, :)), title("human fft\_46\_.txt");
% subplot 211, plot(x, data(1:16800, :)), title("empty seat");
% subplot 212, plot(x, data(16801:end,:)), title("human");

% data_path_2 = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-data\2022.04.14\all_data.xls";
% % data_path_2 = "all_human_data.xls";
% 
% data_2 = readmatrix(data_path_2);
% 
% % data_2 = data_2(1:7200, :);
% 
% subplot 212, plot(x, data_2);