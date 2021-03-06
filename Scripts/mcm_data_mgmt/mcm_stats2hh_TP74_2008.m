% function [vars vars_backup] = mcm_stats2hh(year, site)

%%%% TO BE REMOVED AFTER OPERATIONAL:
 year = 2008; 
% site = 'TP74';
site = 'TP02';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paths and Tags:
switch site
    case 'TP74';        tag = 'hMCM2.mat';
    case 'TP02';        tag = 'hMCM3.mat';
end

yr_str = num2str(year); 
loadstart = addpath_loadstart;
log_path = [loadstart '/SiteData/logs/'];
load_path = [loadstart 'SiteData/' site '/MET-DATA/'];
%%%%%%%%%%%%%%%%%%%%%
%% Enter information about the variables (paths and names)
vars = struct;
vars_backup = struct;

vars(1).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.Fc';             vars(1).name = 'Fc';
vars(2).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.Ustar';          vars(2).name = 'Ustar';
vars(3).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.Hs';             vars(3).name = 'Hs';
vars(4).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.Htc';            vars(4).name = 'Htc';
vars(5).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.LE_L';           vars(5).name = 'LE_L';
vars(6).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.LE_K';           vars(6).name = 'LE_K';

vars(7).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.MiscVariables.Penergy';      vars(7).name = 'Penergy';
vars(8).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.MiscVariables.WUE';          vars(8).name = 'WUE';
vars(9).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.MiscVariables.HR_coeff';     vars(9).name = 'HE_coeff';
vars(10).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.MiscVariables.B_L';         vars(10).name = 'B_L';
vars(11).path = 'MainEddy.Three_Rotations.LinDtr.Fluxes.MiscVariables.B_K';         vars(11).name = 'B_K';

vars(12).path = 'MainEddy.Three_Rotations.Angles.Eta';      vars(12).name = 'Eta';
vars(13).path = 'MainEddy.Three_Rotations.Angles.Theta';    vars(13).name = 'Theta';
vars(14).path = 'MainEddy.Three_Rotations.Angles.Beta';     vars(14).name = 'Beta';

vars(15).path = 'MiscVariables.BarometricP';                vars(15).name = 'BarometricP';
vars(16).path = 'MiscVariables.Tair';                       vars(16).name = 'Tair';

vars(17).path = 'Instrument(1,3).Avg(1)';   vars(17).name = 'CO2_irga';
vars(18).path = 'Instrument(1,3).Avg(2)';   vars(18).name = 'H20_irga';
vars(19).path = 'Instrument(1,4).Avg(1)';   vars(19).name = 'u';
vars(20).path = 'Instrument(1,4).Avg(2)';   vars(20).name = 'v';
vars(21).path = 'Instrument(1,4).Avg(3)';   vars(21).name = 'w';
vars(22).path = 'Instrument(1,4).Avg(5)';   vars(22).name = 'T_s';

vars(23).path = 'Instrument(1,4).Std(1)';   vars(23).name = 'u_std';
vars(24).path = 'Instrument(1,4).Std(2)';   vars(24).name = 'v_std';
vars(25).path = 'Instrument(1,4).Std(3)';   vars(25).name = 'w_std';
%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Make NaNs in all data places:
% for j = 1:1:length(vars)
%     vars(j).data(1:48*length(Day),1) = NaN;
%     vars_backup(j).data(1:48*length(Day),1) = NaN;
% end


YY = yr_str(3:4);
[Mon Day] = make_Mon_Day(year, 1440);
if isleapyear(year) == 1; num_days = 366; else num_days = 365; end
hhour_output = NaN.*ones(48.*num_days,length(vars));
hhour_field_output = NaN.*ones(48.*num_days,length(vars));
%% Load data file tracker if it exists... If not, make a new one:
if exist([log_path site '_hhour_tracker_' yr_str '.dat'],'file') == 2;
    hhour_tracker = load([log_path site '_hhour_tracker_' yr_str '.dat']);
else
    hhour_tracker = NaN.*ones(num_days,4);
end

%%% Make the tracker list for both /hhour and /hhour_field:
for k = 1:1:num_days
    MM = create_label(Mon(k,1),2); DD = create_label(Day(k,1),2); 
    datastr(k,:) = [YY MM DD];
    hhour_tracker(k,1) = str2double(datastr(k,:));
    hhour_tracker(k,2) = ceil(exist([load_path 'hhour/' datastr(k,:) '.' tag])./10);
    hhour_tracker(k,3) = ceil(exist([load_path 'hhour_field/' datastr(k,:) '.' tag])./10);
    hhour_tracker(k,4) = ceil((hhour_tracker(k,2)+hhour_tracker(k,3))./10);
clear MM DD;
end

%%% start loading in files and placing them in the master:
for j = 1:1:num_days
    
%     if j  == 365;
%     disp('stop. hammer time');
%     end
    %%%%%%% Loop for Processed hhour files
    if hhour_tracker(j,2) == 1;
        tmp_hhour = load([load_path 'hhour/' datastr(j,:) '.' tag]);
        for hh_ctr = 1:1:48
           for i = 1:1:length(vars)  
            try
                hhour_output(j.*48 + hh_ctr - 48,i) = eval(['tmp_hhour.Stats(1,hh_ctr).' vars(i).path]);
            catch
                hhour_output(j.*48 + hh_ctr - 48,i) = NaN;
            end          
           end
        end
    else
        hhour_output(j*48-47 : j*48 ,:) = NaN;
    end
    clear tmp_hhour
    %%%%%%%%%%% Loop for field hhour files:
    if hhour_tracker(j,3) == 1;
        tmp_hhour_field = load([load_path 'hhour_field/' datastr(j,:) '.' tag]);
        for hh_ctr = 1:1:48
           for i = 1:1:length(vars)  
            try
                hhour_field_output(j.*48 + hh_ctr - 48,i) = eval(['tmp_hhour_field.Stats(1,hh_ctr).' vars(i).path]);
            catch
                hhour_field_output(j.*48 + hh_ctr - 48,i) = NaN;
            end          
           end
        end
    else
        hhour_field_output(j*48-47 : j*48 ,:) = NaN;
    end
        clear tmp_hhour_field;
        
        %%%% Display an update on progress every 100 days:
        if rem(j,100) == 0;   disp(['Working on Day: ' num2str(j)]);   end
        
end
    
for j = 1:1:length(vars)
    figure('Name',vars(j).name); clf;
    plot(hhour_output(:,j),'b.-');
    hold on;
    plot(hhour_field_output(:,j),'r.-');
    legend('hhour-lab','hhour-field');
end


    
%     
%     
%     
%     
%     if hhour_tracker(j,3) == 1;
%         tmp_hhour = load([load_path 'hhour_filed/' datastr '.' tag]);
%     else
%     end
%     
%     
%         
%     
%     
% 
% 
% 
% 
% skip_raw(1:length(Day),1:2) = 0;
% 
% 
% for i = 50:-1:10
%     mo(i,1:2) = create_label(Mon(i,1),2);
%     da(i,1:2) = create_label(Day(i,1),2);
% bad_data_list = [str2num([YY mo(i,:) da(i,:)]) ; bad_data_list];
% end
% 
% 
% %%% Fill data from hhour files:
% 
% % tic;
% for i = 1:1:length(Day)
%     mo(i,1:2) = create_label(Mon(i,1),2);
%     da(i,1:2) = create_label(Day(i,1),2);
% 
%     % if not 0, then we know there's a match somewhere and we should load
%     % backup file
%     if find(str2num([YY mo(i,:) da(i,:)]) == bad_data_list(:,1)) ~= 0
%         try
%             backup = load([loadstart 'Matlab/Data/Flux/CPEC/TP74/Raw_fieldPC/' YY mo(i,:) da(i,:) '.' tag '.mat']);
%         catch
%             disp(['Could not load backup file for ' yr_str mo(i,:) da(i,:)]);
%             backup = [];
%         end
%     else
%         backup = [];
%     end
% 
%     % Load stats from in-lab processed data:
%     try
%         load([load_path  YY mo(i,:) da(i,:) '.' tag '.mat']);
%     catch
%         skip_raw(i,1) = 1;
%         disp(['Could not load main file for ' YY mo(i,:) da(i,:)]);
%     end
% 
%     % Also try to load stats frim in-field processed data:
%     %     try
%     %         backup = load([loadstart 'Matlab/Data/Flux/CPEC/TP74/Raw_fieldPC/' yr_str mo(i,:) da(i,:) '.' tag '.mat']);
%     %     catch
%     %         skip_raw(i,2) = 1;
%     %     end
% 
%     %% If both stats files are missing, skip the entire day
%     if skip_raw(i,1) == 1 && skip_raw(i,2) == 1;  %In the case that it can't find any stats file
%         disp([' Both processed and backup stats files are missing for ' YY mo(i,:) da(i,:)]);
%     else
% 
% 
% 
%         if ~isempty(backup)
%             for hh = 1:1:48
% 
%                 for j = 1:1:length(vars)
%                     try
%                         vars_backup(j).data(48.*(i-1)+hh,1) = eval(['backup.Stats(1,hh).' vars(j).path]);
%                     catch
%                     end
%                 end
%             end
%         else
%         end
% 
% 
% 
% 
%         %%% GO through half-hours
%         for hh = 1:1:48
% 
%             for j = 1:1:length(vars)
%                 try
%                     vars(j).data(48.*(i-1)+hh,1) = eval(['Stats(1,hh).' vars(j).path]);
%                 catch
%                 end
%                 %                 try
%                 %                     vars_backup(j).data(48.*(i-1)+hh,1) = eval(['backup.Stats(1,hh).' vars(j).path]);
%                 %                 catch
%                 %                 end
% 
%                 %                     disp(['little problem in ' yr_str mo(i,:) da(i,:)]);
%             end
%         end
%         %                 a(48.*(i-1)+hh,1) = Stats(1,hh).MainEddy.Three_Rotations.LinDtr.Fluxes.Fc;
%         %                 b(48.*(i-1)+hh,1) = vars(1).data(48.*(i-1)+hh,1);
% 
%         %%%% Covariances are in Stats(1,hh).Instrument(1,4).Cov;
%     end
%     %     catch
%     % disp(['could not load the file for ' yr_str mo(i,:) da(i,:)]);
%     clear Stats %backup;
% %     t = toc
% end
% 
% 
% 
% disp('done!')
% 
% day_ticks = (1:48:length(vars(1).data)-47)';
% 
% for k = 1:1:length(Day)
%     plot_label(k,:) = [mo(k,:) '/' da(k,:)];
% end
% 
% %%% Plots Fc
% figure(1);clf
% plot(vars(1).data); hold on;
% plot(vars_backup(1).data,'r')
% set(gca,'XTick',day_ticks);
% set(gca,'XTickLabel',plot_label)
% 
% 
% figure(2);clf;
% plot(vars(15).data); hold on;
% plot(vars(16).data,'r')
% plot(vars_backup(15).data,'c');
% plot(vars_backup(16).data,'m');
% 
% 
% figure(3);clf
% plot(vars(17).data); hold on;
% plot(vars_backup(17).data,'m'); 
% 
% save('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/calc_vars.mat','vars');
% save('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/calc_vars_backup.mat','vars_backup');
% 
% % load pressure and temperature data and use it to correct fluxes:
% 
% Ta = load('/home/brodeujj/Matlab/Data/Met/Final_Filled/TP74/TP74_2008.Ta');
% APR = load('/home/brodeujj/Matlab/Data/Met/Final_Filled/TP74/TP74_2008.APR');
% PAR = load('/home/brodeujj/Matlab/Data/Met/Final_Filled/TP74/TP74_2008.PAR');
% 
% Fc_1 = vars(1).data;
% Fc_b = vars_backup(1).data;
% CO2_1 = vars(17).data;
% CO2_b = vars_backup(17).data;
% P_1 = vars(15).data; P_b = vars_backup(15).data; 
% T_1 = vars(16).data; T_b = vars_backup(16).data; 
% T_1(1:450) = NaN;
% P_1(isnan(P_1)) = 94.5;
% T_1(isnan(T_1)) = Ta(isnan(T_1));
% 
% figure(5);clf;
% plot(P_1,'b');
% hold on;
% plot(T_1,'r');
% 
% 
% Fc_b(CO2_b == 0,1) = NaN;
% CO2_b(CO2_b == 0,1) = NaN;
% CO2_1(CO2_1<360,1) = NaN;
% CO2_b(CO2_b<360,1) = NaN;
% 
% 
% 
% figure(1); clf;
% plot(Fc_1,'b'); hold on;
% plot(Fc_b,'r');
% figure(2);clf
% plot(CO2_1,'b'); hold on;
% plot(CO2_b,'r');
% 
% 
% %Correction factor for T and P:
% C = (APR./P_1).* (T_1./Ta);
% Fc_1(isnan(Fc_1)) = Fc_b(isnan(Fc_1));
% Fc = Fc_1.*C;
% Fc(Fc > 80) = NaN;
% figure(10);
% plot(Fc)
% 
% ustar = vars(2).data;
% ustar_b = vars_backup(2).data;
% 
% figure(11);clf
% plot(ustar); hold on;
% plot(ustar_b,'r'); 
% 
% ustar(abs(ustar)> 2) = NaN;
% 
% save('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/Organized/TP74_2008.Fc','Fc','-ASCII');
% save('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/Organized/TP74_2008.CO2','CO2_1','-ASCII');
% save('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/Organized/TP74_2008.ustar','ustar','-ASCII');
% 
% %% 
% 
% load('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/calc_vars.mat');
% load('/home/brodeujj/Matlab/Data/Flux/CPEC/TP74/calc_vars_backup.mat');



