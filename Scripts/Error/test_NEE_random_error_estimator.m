% test_NEE_random_error_estimator

clear all;
close all;
% Info:
year_start = 2003;
year_end = 2009;
site = 'TP02';
Ustar_th = 0.325;
ls = addpath_loadstart;
load_path = [ls 'Matlab/Data/Master_Files/' site '/'];
load([load_path site '_gapfill_data_in.mat']);
data = trim_data_files(data,year_start, year_end,1);
data.site = site;
data.SM = data.SM_a_filled; %clear SM;

% data.VPD = VPD_calc(data.RH, data.Ta);
% [junk, data.GDD] = GDD_calc(data.Ta,10,48,year_start:1:year_end);

    data.NEEstd_v3 = NEE_random_error_estimator_v3(data, [], Ustar_th,1);
    data.NEEstd_v4 = NEE_random_error_estimator_v4(data, [], Ustar_th,1);
    data.NEEstd_v5 = NEE_random_error_estimator_v5(data, [], [],1);
    data.NEEstd_v6 = NEE_random_error_estimator_v6(data, [], [],1);

    figure('Name','std_comp');clf;
    plot(data.NEEstd_v3,'b');hold on;
    plot(data.NEEstd_v4,'r');
        plot(data.NEEstd_v5,'g');