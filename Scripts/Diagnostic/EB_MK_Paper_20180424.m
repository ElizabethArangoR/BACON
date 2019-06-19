%% Load or create data
ls = addpath_loadstart;
% save_path = [ls 'Matlab/Data/Flux/Gapfilling/' site '/'];
footprint_path = [ls 'Matlab/Data/Flux/Footprint/'];
save_path = [ls 'Matlab/Data/Diagnostic/'];
if exist([ls 'Matlab/Data/Diagnostic/EB_MK_Paper.mat'],'file')~=2
    
    %%% Load TPD Data:
    site = 'TPD';
    year_start = 2012;
    year_end = 2018;
    
    load_path = [ls 'Matlab/Data/Master_Files/' site '/'];
    load([load_path site '_gapfill_data_in.mat']);
    data = trim_data_files(data,year_start, year_end,1);
    data.site = site; close all
    data.costfun = 'WSS';
    data.min_method = 'NM';
    % orig.data = data; % save the original data:
    NEE_orig = data.NEE;
    
    %%% Load Footprint file, apply footprint filter
    load([footprint_path site '_footprint_flag.mat'])
    tmp_fp_flag = footprint_flag.Kljun70;
    % Flag file for Kljun 75% footprint:
    fp_flag(:,1) = tmp_fp_flag(tmp_fp_flag(:,1) >= data.year_start & tmp_fp_flag(:,1) <= data.year_end,2);
    % Flag file for No footprint:
    fp_flag(:,2) = ones(length(fp_flag(:,1)),1); % The
    data.NEE = NEE_orig.*fp_flag(:,1);
    
    %%% Calculate and apply Ustar threshold
    Ustar_th_Reich = mcm_Ustar_th_Reich(data,0);
    Ustar_th_JJB = mcm_Ustar_th_JJB(data,0);
    data.Ustar_th = Ustar_th_Reich(:,1);
    
    %%% Estimate random error:
    [data.NEE_std, f_fit, f_std] = NEE_random_error_estimator_v6(data,[],[],0);
    
    TPD.data = data;
    clear data;
    
    
    
    %% Load & calc TP39 data
    clear fp_flag;
    site = 'TP39';
    year_start = 2004;
    year_end = 2018;
    
    ls = addpath_loadstart;
    load_path = [ls 'Matlab/Data/Master_Files/' site '/'];
    % save_path = [ls 'Matlab/Data/Flux/Gapfilling/' site '/'];
    footprint_path = [ls 'Matlab/Data/Flux/Footprint/'];
    
    load([load_path site '_gapfill_data_in.mat']);
    data = trim_data_files(data,year_start, year_end,1);
    data.site = site; close all
    data.costfun = 'WSS';
    data.min_method = 'NM';
    % orig.data = data; % save the original data:
    NEE_orig = data.NEE;
    
    %%% Load Footprint file, apply footprint filter
    load([footprint_path site '_footprint_flag.mat'])
    tmp_fp_flag = footprint_flag.Kljun70;
    % Flag file for Kljun 75% footprint:
    fp_flag(:,1) = tmp_fp_flag(tmp_fp_flag(:,1) >= data.year_start & tmp_fp_flag(:,1) <= data.year_end,2);
    % Flag file for No footprint:
    fp_flag(:,2) = ones(length(fp_flag(:,1)),1); % The
    data.NEE = NEE_orig.*fp_flag(:,1);
    
    %%% Calculate and apply Ustar threshold
    Ustar_th_Reich = mcm_Ustar_th_Reich(data,0);
    Ustar_th_JJB = mcm_Ustar_th_JJB(data,0);
    data.Ustar_th = Ustar_th_Reich(:,1);
    
    %%% Estimate random error:
    [data.NEE_std, f_fit, f_std] = NEE_random_error_estimator_v6(data,[],[],0);
    
    TP39.data = data;
    clear data;
    
    
    
    save([save_path 'EB_MK_Paper.mat']);
    
else
    load([save_path 'EB_MK_Paper.mat']);
end

% TPD.data = TPD.data(TPD.data
%% RE
clear data;
sites = {'TP39';'TPD'};
begin_year_main = 2004;
end_year_main = 2018;

for i = 1:1:length(sites)
    close all; clear options;
    site = sites{i,1};
    data = eval([site '.data;']);
    
    if isnan(begin_year_main)==1
        begin_year = min(data.Year);
    else
        begin_year = max(begin_year_main, data.Year(1));
    end
    
    if isnan(end_year_main)==1
        end_year = max(data.Year);
    else
        end_year = min(end_year_main, data.Year(end));
    end
    
    data = trim_data_files(data,begin_year,end_year);
    
    %%%%%%%%%%%% RE %%%%%%%%%%%%%%%%%
    ind_param(1).RE_all = find((data.PAR >= 15 |data.Ustar >= data.Ustar_th) & data.RE_flag == 2 & ~isnan(data.Ts5.*data.SM_a_filled.*data.NEE.*data.NEE_std));
    
    %%% Q10 Model
    %%%%%% Ts parameterization only:
    clear global;
    options.costfun=data.costfun; options.min_method = data.min_method;
    [c_hat(1).RE1all, y_hat(1).RE1all, y_pred(1).RE1all, stats(1).RE1all, sigma(1).RE1all, err(1).RE1all, exitflag(1).RE1all, num_iter(1).RE1all] = ...
        fitresp([2 3 8 180], 'fitresp_3B', [data.Ts5(ind_param(1).RE_all) data.SM_a_filled(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM_a_filled], data.NEE_std(ind_param(1).RE_all), options);
    
    %%%%%% Ts + SM parameterization:
    clear global;
    options.costfun =data.costfun; options.min_method = data.min_method; options.f_coeff = [NaN NaN];
    [c_hat(1).RE1all_Tsonly, y_hat(1).RE1all_Tsonly, y_pred(1).RE1all_Tsonly, stats(1).RE1all_Tsonly, sigma(1).RE1all_Tsonly, err(1).RE1all_Tsonly, exitflag(1).RE1all_Tsonly, num_iter(1).RE1all_Tsonly] = ...
        fitresp([2 3], 'fitresp_3A', [data.Ts5(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5], data.NEE_std(ind_param(1).RE_all), options);
    
    %%% Logistic Model
    %%%%%% Ts parameterization only:
    clear global;
    options.costfun =data.costfun; options.min_method = data.min_method;
    [c_hat(1).RE2all_Tsonly, y_hat(1).RE2all_Tsonly, y_pred(1).RE2all_Tsonly, stats(1).RE2all_Tsonly, sigma(1).RE2all_Tsonly, err(1).RE2all_Tsonly, exitflag(1).RE2all_Tsonly, num_iter(1).RE2all_Tsonly] = ...
        fitresp([8 0.2 12], 'fitresp_2A', data.Ts5(ind_param(1).RE_all), data.NEE(ind_param(1).RE_all), data.Ts5, data.NEE_std(ind_param(1).RE_all), options);
    
    %%%%%% Ts + SM parameterization:
    clear global;
    options.costfun =data.costfun; options.min_method = data.min_method;
    [c_hat(1).RE2all, y_hat(1).RE2all, y_pred(1).RE2all, stats(1).RE2all, sigma(1).RE2all, err(1).RE2all, exitflag(1).RE2all, num_iter(1).RE2all] = ...
        fitresp([8,0.2,12,8,180], 'fitresp_2B', [data.Ts5(ind_param(1).RE_all) data.SM_a_filled(ind_param(1).RE_all)], data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM_a_filled], data.NEE_std(ind_param(1).RE_all), options);
    
    %%%%%% Calculate and plot residuals
    resids.RE2all_Tsonly = data.NEE(ind_param(1).RE_all) - y_pred(1).RE2all_Tsonly(ind_param(1).RE_all);
    resids.RE2all = data.NEE(ind_param(1).RE_all) - y_pred(1).RE2all(ind_param(1).RE_all);
    
    resids.RE1all_Tsonly = data.NEE(ind_param(1).RE_all) - y_pred(1).RE1all_Tsonly(ind_param(1).RE_all);
    resids.RE1all = data.NEE(ind_param(1).RE_all) - y_pred(1).RE1all(ind_param(1).RE_all);
    
    %  [mov_avg_RE1] = jjb_mov_avg(data_in,winsize, st_option,lag_option)
    [mov_avg_RE1_fixSM] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).RE_all),resids.RE1all_Tsonly, 0.005, 0.01);
    [mov_avg_RE2_fixSM] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).RE_all),resids.RE2all_Tsonly, 0.005, 0.01);
    [mov_avg_RE1] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).RE_all),resids.RE1all, 0.005, 0.01);
    [mov_avg_RE2] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).RE_all),resids.RE2all, 0.005, 0.01);
    
    f1 = figure(1);clf;
    subplot(2,1,1)
    plot(data.SM_a_filled(ind_param(1).RE_all),resids.RE1all,'c.');hold on;
    plot(data.SM_a_filled(ind_param(1).RE_all),resids.RE1all_Tsonly,'.','Color',[0.7,0.7,0.7]);hold on;
    h1(1)= plot(mov_avg_RE1(:,1),mov_avg_RE1(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h1(2)= plot(mov_avg_RE1_fixSM(:,1),mov_avg_RE1_fixSM(:,2),'k.-','LineWidth',2);
    axis([0.045 0.1 -2 1]);
    ylabel('RE_{meas} - RE_{pred}');
    xlabel('VWC');
    legend(h1,'Q10 - all','Q10 - no SM')
    
    subplot(2,1,2)
    plot(data.SM_a_filled(ind_param(1).RE_all),resids.RE2all,'c.');hold on;
    plot(data.SM_a_filled(ind_param(1).RE_all),resids.RE2all_Tsonly,'.','Color',[0.7,0.7,0.7]);hold on;
    h1(1)= plot(mov_avg_RE2(:,1),mov_avg_RE2(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h1(2)= plot(mov_avg_RE2_fixSM(:,1),mov_avg_RE2_fixSM(:,2),'k.-','LineWidth',2);
    axis([0.045 0.1 -2 1]);
    ylabel('RE_{meas} - RE_{pred}');
    xlabel('VWC');
    legend(h1,'Logi - all','Logi - no SM')
    
    print(f1, [save_path site '_REmodel_resids_' num2str(begin_year) '-' num2str(end_year) '.png'],'-dpng','-r300');
    
    %%%%%%%%%%%%%%% Plot scaling relationships
    figure(2);clf;
    %%% SM relationship - Q10
    [x_out, y_out] = plot_SMlogi(c_hat.RE1all(3:4), 0);
    subplot(2,1,1);
    plot(x_out,y_out,'b-','LineWidth',2);
    ylabel('scaling factor');
    xlabel('VWC');
    title('Q10 model')
    grid on;
    axis([0.04 0.075 0 1]);
    
    %%% SM relationship - Logi
    [x_out, y_out] = plot_SMlogi(c_hat.RE2all(4:5), 0);
    subplot(2,1,2);
    plot(x_out,y_out,'b-','LineWidth',2);
    ylabel('scaling factor');
    xlabel('VWC');
    title('Logi model')
    grid on;
    axis([0.04 0.075 0 1]);
    
    print([save_path site '_REmodel_scalingfactors_' num2str(begin_year) '-' num2str(end_year) '.png'],'-dpng','-r300');
    
    %%%%%%%%%%%%%%%%%%%%%% GEP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RE_model = y_pred(1).RE2all_Tsonly;
    
    GEPraw = RE_model - data.NEE;
    %%% Set GEP to zero when PAR < 15:
    % GEPraw(data.PAR < 15) = NaN;
    %%% Updated May 19, 2011 by JJB:
    GEPraw(data.PAR < 15 | (data.PAR <= 150 & data.Ustar < data.Ustar_th) ) = NaN;
    
    GEP_model = zeros(length(GEPraw),1);
    GEP_pred = NaN.*ones(length(GEPraw),1);
    GEP_pred_fixed = NaN.*ones(length(GEPraw),1);
    GEP_pred_fixed_noSM = NaN.*ones(length(GEPraw),1);
    
    %%% Index for all hhours available for parameterization of an all-years
    %%% relationship:
    % ind_param(1).GEPallold = find(data.Ts2 > 0.5 & data.Ta > 2 & data.PAR > 15 & ~isnan(GEPraw.*data.NEE_std.*data.SM_a_filled) & data.VPD > 0 & data.Ustar > data.Ustar_th);
    ind_param(1).GEPall = find(~isnan(GEPraw.*data.NEE_std.*data.SM_a_filled.*data.Ts5.*data.PAR) & data.GEP_flag==2 & data.VPD > 0);
    
    clear options global;
    %%% Set inputs for all-years parameterization
    options.costfun =data.costfun; options.min_method = data.min_method;
    options.f_coeff = NaN.*ones(1,8);
    X_in = [data.PAR(ind_param(1).GEPall) data.Ts5(ind_param(1).GEPall) data.VPD(ind_param(1).GEPall) data.SM_a_filled(ind_param(1).GEPall)];
    X_eval = [data.PAR data.Ts5 data.VPD data.SM_a_filled];
    %%% All-years parameterization, All variables fitted:
    [c_hat(1).GEPall, y_hat(1).GEPall, y_pred(1).GEPall, stats(1).GEPall, sigma(1).GEPall, err(1).GEPall, exitflag(1).GEPall, num_iter(1).GEPall] = ...
        fitGEP([0.1 40 2 0.5 -2 -0.8 8 180], 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix Ts5 relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(3:4) = [-10000 100];
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixTs, y_hat(1).GEP_fixTs, y_pred(1).GEP_fixTs, stats(1).GEP_fixTs, sigma(1).GEP_fixTs, err(1).GEP_fixTs, exitflag(1).GEP_fixTs, num_iter(1).GEP_fixTs] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix VPD relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(5:6) = [-10000 100];
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixVPD, y_hat(1).GEP_fixVPD, y_pred(1).GEP_fixVPD, stats(1).GEP_fixVPD, sigma(1).GEP_fixVPD, err(1).GEP_fixVPD, exitflag(1).GEP_fixVPD, num_iter(1).GEP_fixVPD] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix SM relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(7:8) = [-10000 100];
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixSM, y_hat(1).GEP_fixSM, y_pred(1).GEP_fixSM, stats(1).GEP_fixSM, sigma(1).GEP_fixSM, err(1).GEP_fixSM, exitflag(1).GEP_fixSM, num_iter(1).GEP_fixSM] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix Ts5+VPD relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(3:6) = [-10000 100 -10000 100];
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixTsVPD, y_hat(1).GEP_fixTsVPD, y_pred(1).GEP_fixTsVPD, stats(1).GEP_fixTsVPD, sigma(1).GEP_fixTsVPD, err(1).GEP_fixTsVPD, exitflag(1).GEP_fixTsVPD, num_iter(1).GEP_fixTsVPD] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix Ts5+SM relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(3:4) = [-10000 100];
    options.f_coeff(7:8) = [-10000 100];
    
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixTsSM, y_hat(1).GEP_fixTsSM, y_pred(1).GEP_fixTsSM, stats(1).GEP_fixTsSM, sigma(1).GEP_fixTsSM, err(1).GEP_fixTsSM, exitflag(1).GEP_fixTsSM, num_iter(1).GEP_fixTsSM] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix SM+VPD relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(5:6) = [-10000 100];
    options.f_coeff(7:8) = [-10000 100];
    
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixVPDSM, y_hat(1).GEP_fixVPDSM, y_pred(1).GEP_fixVPDSM, stats(1).GEP_fixVPDSM, sigma(1).GEP_fixVPDSM, err(1).GEP_fixVPDSM, exitflag(1).GEP_fixVPDSM, num_iter(1).GEP_fixVPDSM] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    %%% All-years parameterization, fix all but PAR relationship:
    clear global;
    options.f_coeff = NaN.*ones(size(c_hat(1).GEPall));
    options.f_coeff(3:4) = [-10000 100];
    options.f_coeff(5:6) = [-10000 100];
    options.f_coeff(7:8) = [-10000 100];
    
    % [x_out, y_out] = plot_SMlogi([-10000 100], 1);
    [c_hat(1).GEP_fixall, y_hat(1).GEP_fixall, y_pred(1).GEP_fixall, stats(1).GEP_fixall, sigma(1).GEP_fixall, err(1).GEP_fixall, exitflag(1).GEP_fixall, num_iter(1).GEP_fixall] = ...
        fitGEP(c_hat(1).GEPall, 'fitGEP_1H1_3L6', X_in,GEPraw(ind_param(1).GEPall),  X_eval, data.NEE_std(ind_param(1).GEPall), options);
    
    
    
    %%% Compile a table of R2 stats and contributions:
    
    model_names = {'RE-all (Ts+SM)';'RE-noSM';'GEP-all (PAR+Ts+VPD+SM)';'GEP-noTs';'GEP-noVPD';'GEP-noSM'};
    rsqs = [stats.RE2all.R2; stats.RE2all_Tsonly.R2; stats.GEPall.R2; stats.GEP_fixTs.R2; stats.GEP_fixVPD.R2; stats.GEP_fixSM.R2];
    T_rsq = table(model_names,rsqs,'VariableNames',{'model';'R2'});
    writetable(T_rsq,[save_path site '_R2_values_' num2str(begin_year) '-' num2str(end_year) '.txt']);
    
    component_names = {'RE-Ts';'RE-SM';'GEP-PAR';'GEP-Ts';'GEP-VPD';'GEP-SM'};
    rsq_contrib = [stats.RE2all_Tsonly.R2; ...
        stats.RE2all.R2 - stats.RE2all_Tsonly.R2; ...
        stats.GEP_fixall.R2; ...
        stats.GEPall.R2 - stats.GEP_fixTs.R2; ...
        stats.GEPall.R2 - stats.GEP_fixVPD.R2; ...
        stats.GEPall.R2 - stats.GEP_fixSM.R2; ];
    T_contribs = table(component_names,rsq_contrib,'VariableNames',{'variable';'R2'});
    writetable(T_contribs,[save_path site '_R2_contributions_' num2str(begin_year) '-' num2str(end_year) '.txt']);
    
    %%%% PLOTS
    figure(4);clf;
    plot(y_pred(1).GEPall,'b-','LineWidth',2);hold on;
    plot(y_pred(1).GEP_fixTs,'r-');
    plot(y_pred(1).GEP_fixVPD,'y-');
    plot(y_pred(1).GEP_fixSM,'c-');
    plot(y_pred(1).GEP_fixTsVPD,'m-');
    plot(y_pred(1).GEP_fixTsSM,'k-');
    plot(y_pred(1).GEP_fixVPDSM,'g-');
    print([save_path site '_GEPmodel_results_' num2str(begin_year) '-' num2str(end_year) '.png'],'-dpng','-r300');
    
    
    %%%% Residuals
    resids.GEPall = GEPraw(ind_param(1).GEPall) - y_pred(1).GEPall(ind_param(1).GEPall);
    resids.GEP_fixTs = GEPraw(ind_param(1).GEPall) - y_pred(1).GEP_fixTs(ind_param(1).GEPall);
    resids.GEP_fixVPD = GEPraw(ind_param(1).GEPall) - y_pred(1).GEP_fixVPD(ind_param(1).GEPall);
    resids.GEP_fixSM = GEPraw(ind_param(1).GEPall) - y_pred(1).GEP_fixSM(ind_param(1).GEPall);
    
    %  [mov_avg_RE1] = jjb_mov_avg(data_in,winsize, st_option,lag_option)
    [mov_avg_GEPall_Ts] = jjb_mov_window_stats(data.Ts5(ind_param(1).GEPall),resids.GEPall, 0.01, 0.01);
    [mov_avg_GEP_fixTs] = jjb_mov_window_stats(data.Ts5(ind_param(1).GEPall),resids.GEP_fixTs, 0.01, 0.01);
    
    [mov_avg_GEPall_VPD] = jjb_mov_window_stats(data.VPD(ind_param(1).GEPall),resids.GEPall, 0.01, 0.01);
    [mov_avg_GEP_fixVPD] = jjb_mov_window_stats(data.VPD(ind_param(1).GEPall),resids.GEP_fixVPD, 0.01, 0.01);
    [mov_avg_GEP_fixVPD_bySM] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).GEPall),resids.GEP_fixVPD, 0.005, 0.01);
    
    
    [mov_avg_GEPall_SM] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).GEPall),resids.GEPall, 0.005, 0.01);
    [mov_avg_GEP_fixSM] = jjb_mov_window_stats(data.SM_a_filled(ind_param(1).GEPall),resids.GEP_fixSM, 0.005, 0.01);
    
    
    
    figure(5);clf
    %%% Ts
    subplot(2,2,1)
    plot(data.Ts5(ind_param(1).GEPall),resids.GEPall,'c.');hold on;
    plot(data.Ts5(ind_param(1).GEPall),resids.GEP_fixTs,'.','Color',[0.7,0.7,0.7]);hold on;
    h1(1)= plot(mov_avg_GEPall_Ts(:,1),mov_avg_GEPall_Ts(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h1(2)= plot(mov_avg_GEP_fixTs(:,1),mov_avg_GEP_fixTs(:,2),'k.-','LineWidth',2);
    axis([4 24 -20 20]);
    ylabel('GEP_{meas} - GEP_{pred}');
    xlabel('Ts5');
    legend(h1,'GEP-all','GEP-noTs')
    
    %%% VPD
    subplot(2,2,2)
    plot(data.VPD(ind_param(1).GEPall),resids.GEPall,'c.');hold on;
    plot(data.VPD(ind_param(1).GEPall),resids.GEP_fixVPD,'.','Color',[0.7,0.7,0.7]);hold on;
    h2(1)= plot(mov_avg_GEPall_VPD(:,1),mov_avg_GEPall_VPD(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h2(2)= plot(mov_avg_GEP_fixVPD(:,1),mov_avg_GEP_fixVPD(:,2),'k.-','LineWidth',2);
    axis([-1 36 -20 20]);
    ylabel('GEP_{meas} - GEP_{pred}');
    xlabel('VPD (hPa)');
    legend(h2,'GEP-all','GEP-noVPD')
    
    %%% SM
    subplot(2,2,3)
    plot(data.SM_a_filled(ind_param(1).GEPall),resids.GEPall,'c.');hold on;
    plot(data.SM_a_filled(ind_param(1).GEPall),resids.GEP_fixSM,'.','Color',[0.7,0.7,0.7]);hold on;
    h3(1)= plot(mov_avg_GEPall_SM(:,1),mov_avg_GEPall_SM(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h3(2)= plot(mov_avg_GEP_fixSM(:,1),mov_avg_GEP_fixSM(:,2),'k.-','LineWidth',2);
    axis([0.03 0.2 -1 1]);
    ylabel('GEP_{meas} - GEP_{pred}');
    xlabel('SM');
    legend(h3,'GEP-all','GEP-noSM')
    
    %%% VPD by SM
    subplot(2,2,4)
    plot(data.SM_a_filled(ind_param(1).GEPall),resids.GEPall,'c.');hold on;
    plot(data.SM_a_filled(ind_param(1).GEPall),resids.GEP_fixVPD,'.','Color',[0.7,0.7,0.7]);hold on;
    h4(1)= plot(mov_avg_GEPall_SM(:,1),mov_avg_GEPall_SM(:,2),'.-','Color',[0 0 1],'LineWidth',2);
    h4(2)= plot(mov_avg_GEP_fixVPD_bySM(:,1),mov_avg_GEP_fixVPD_bySM(:,2),'k.-','LineWidth',2);
    axis([0.03 0.2 -1 1]);
    ylabel('GEP_{meas} - GEP_{pred}');
    xlabel('SM');
    legend(h4,'GEP-all','GEP-noVPD')
    
    print([save_path site '_GEPmodel_resids_' num2str(begin_year) '-' num2str(end_year) '.png'],'-dpng','-r300');
    
    %%%%%%%%%%%%%%% Plot scaling relationships
    figure(6);clf;
    %%% TS relationship
    [x_out, y_out] = plot_SMlogi(c_hat.GEPall(3:4), 0);
    subplot(2,2,1);
    plot(x_out,y_out,'b-','LineWidth',2);
    ylabel('scaling factor');
    xlabel('Ts');
    grid on;
    axis([-2 25 0 1]);
    
    %%% VPD relationship
    [x_out, y_out] = plot_SMlogi(c_hat.GEPall(5:6), 0);
    subplot(2,2,2);
    plot(x_out,y_out,'b-','LineWidth',2);
    ylabel('scaling factor');
    xlabel('VPD');
    grid on;
    axis([0 40 0 1]);
    
    %%% SM relationship
    [x_out, y_out] = plot_SMlogi(c_hat.GEPall(7:8), 0);
    subplot(2,2,3);
    plot(x_out,y_out,'b-','LineWidth',2);
    ylabel('scaling factor');
    xlabel('SM');
    grid on;
    axis([0.04 0.075 0 1]);
    
    print([save_path site '_GEPmodel_scalingfactors_' num2str(begin_year) '-' num2str(end_year) '.png'],'-dpng','-r300');
end