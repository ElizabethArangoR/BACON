function [H_filled LE_filled] = mcm_Gapfill_LE_H_WLR_MDV(data, plot_flag)
%%% mcm_Gapfill_LE_H_WLR_MDV.m
%%% usage: [H_filled LE_filled] = mcm_Gapfill_LE_H_WLR_MDV(data)
%%% This function is called by mcm_Gapfill_LE_H.m, and is used to fill
%%% small gaps in H and LE data by means of windowed-linear regression
%%% (WLR) and mean diurnal variation (MDV) methods. Input 'data' is a
%%% structure file containing met and flux data.
%%% Created in current form Aug 1, 2010 by JJB.

%%% Revision History:
%
%
%
%
%

if nargin < 2
    plot_flag = 1;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% FILL GAPS IN H %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H_raw = NaN.*ones(length(data.Year),1);
% H_raw(data.Ustar > Ustar_th) = data.H(data.Ustar > Ustar_th);
if isfield(data,'H_filled')
H_raw = data.H_filled;
else
    H_raw = data.H;
end
H_filled = H_raw;

%% Fill Gaps in H 
x_var1 = data.Rn_filled-data.SHF+data.Jt; %%% Jt is backwards in sign -- -'ve during day, +'ve at night

%%% Model H based on incoming energy for 5-day average window
[H1_fill, H1_model_5]= jjb_WLR_gapfill(x_var1, H_raw, 240,'on'); 
%%% Fill all possible gaps:
H_filled(isnan(H_filled)) = H1_model_5(isnan(H_filled));

%%% Model H based on incoming energy for 10-day average window
[H1_fill, H1_model_10] = jjb_WLR_gapfill(x_var1, H_raw, 480,'on'); 
%%% Fill all possible gaps:
H_filled(isnan(H_filled)) = H1_model_10(isnan(H_filled));

%%% Model H based on incoming energy for 15-day average window
[H1_fill, H1_model_15]= jjb_WLR_gapfill(x_var1, H_raw, 720,'on'); 
%%% Fill all possible gaps:
H_filled(isnan(H_filled)) = H1_model_15(isnan(H_filled));

%%% Model H based on incoming energy for 20-day average window
[H1_fill, H1_model_20]= jjb_WLR_gapfill(x_var1, H_raw, 960,'on'); 
%%% Fill all possible gaps:
H_filled(isnan(H_filled)) = H1_model_20(isnan(H_filled));
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%% Fill LE Gaps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_var2 = x_var1 - H_filled;
LE_raw = NaN.*ones(length(data.Year),1);
if isfield(data, 'LE_filled')
LE_raw = data.LE_filled;
else
    LE_raw = data.LE;
end
LE_filled = LE_raw;
%%% Step 1 - make LE gaps 0 if at night
LE_filled(isnan(LE_filled) & data.PAR <= 20) = 0;

%%% Step 2 - Growing-season daytime LE filling method
%%% Use a moving window approach; the same method as H
% [LE_fill1 LE1_model_5] = jjb_WLR_gapfill(x_var2, LE_raw, 240,'on'); 
% %%% Fill gaps:
% LE_filled(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  ) = LE1_model_5(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  );

%%% 10-day window
[LE_fill2 LE1_model_10] = jjb_WLR_gapfill(x_var2, LE_raw, 480,'on'); 
%%% Fill gaps:
LE_filled(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  ) = LE1_model_10(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  );

%%% 15-day window
[LE_fill3 LE1_model_15] = jjb_WLR_gapfill(x_var2, LE_raw, 720,'on'); 
%%% Fill gaps:
LE_filled(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  ) = LE1_model_15(isnan(LE_filled) & data.PAR > 20 & ((data.dt >= 90 & data.dt <= 330) | data.Ts5 > 2)  );

%%% Step 3 - Non Growing Season daytime LE filling method
%%% Use average 1/2hr value for period five days before to five days after.
LE_fill_MDV = jjb_MDV_gapfill(LE_raw, 10, 48);

LE_filled(isnan(LE_filled) & data.PAR > 20 & (data.dt < 90 | data.dt > 330) & data.Ts5 < 2) = LE_fill_MDV(isnan(LE_filled) & data.PAR > 20 & (data.dt < 90 | data.dt > 330) & data.Ts5 < 2);

%%% Fill in any remaining gaps with MDV
LE_filled(isnan(LE_filled)) = LE_fill_MDV(isnan(LE_filled));

%% Plot H and LE:
if plot_flag == 1
figure('Name', 'filled H and LE');clf
subplot(2,1,1)
plot(H_filled,'r');hold on;
plot(H_raw,'b');
legend('filled','raw');
title('H');
subplot(2,1,2)
plot(LE_filled,'r');hold on;
plot(LE_raw,'b');
legend('filled','raw');
title('LE');
end
%% Calculate Annual Evapotranspiration
%%% Convert LE in W/m^2 to mm/hhour 
%%% by using either (LE/lambda(T_air).*1800) --- What is Lambda?????
%%% or LE/343
%     
% LE_mm = (LE_filled./lambda(data.Ta)).*1800;
% LE_mm(isnan(LE_mm),1) = LE_filled(isnan(LE_mm))./1372;
%   ctr = 1;
%   
% for jj = year_start:1:year_end
% ET(ctr).cumsum = nancumsum(LE_mm(data.Year==jj));
% ET(ctr).sum = ET(ctr).cumsum(end);  
% % ET(ctr).cumsum = nancumsum(LE_filled(year1==jj)./1372);
% % ET(ctr).sum = ET(ctr).cumsum(end);
% % output = [LE_filled(year1==jj) H_filled(year1==jj)];
% % save([path 'M' site '_ETEB_output_' num2str(jj) '.dat'],'output', '-ASCII')
% disp(['year = ' num2str(jj) ': ET = ' num2str(ET(ctr).sum) ])
% ctr = ctr +1;
% end

% master.data.Year = data.Year;
% master.data.LE_filled = LE_filled;
% master.data.H_filled = H_filled;
% 
% save([save_path site '_GapFilled_LE_H_' num2str(year_start) '_' num2str(year_end) '_ustar=' num2str(Ustar_th) '.mat'],'master');
% disp('done!');
