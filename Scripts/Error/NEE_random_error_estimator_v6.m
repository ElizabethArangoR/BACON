function [std_pred f_fit f_std] = NEE_random_error_estimator_v6(data,tol, Ustar_th, plot_flag)
%%% This function estimates the standard deviation associated with NEE 
%%% measurements, as a function of a multilinear relationship with soil
%%% temperature (Ts5) and PAR.
%%% 
%%% The novelty of this version is the use of the multilinear function as
%%% controls on NEE_std, instead of the magnitude of exchanges.

%%% Created 7-Dec-2010 by JJB.

close all;

if nargin < 4
    plot_flag = 0;
end

if ~isfield(data, 'site')
    data.site = input('Enter Site Name: ', 's');
end

% Calculate VPD if it doesn't exist
if isfield(data,'VPD')==0;
    data.VPD = VPD_calc(data.RH, data.Ta);
end
% Calculate GDD if it doesn't exist:
if isfield(data,'GDD')==0;
    [junk data.GDD] = GDD_calc(data.Ta,10,48,[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set the u* threshold (if it's not externally set);
% Do nothing if it already exists in the data file:
if isfield(data,'Ustar_th')==1
else
    % If the field is empty and argin is empty, calculate it with JJB
    % method:
if isempty(Ustar_th)
    data.Ustar_th = mcm_Ustar_th_JJB(data,0);
else
    % If the argin is a constant value, use it for the entire year:
    if numel(Ustar_th) == 1
        data.Ustar_th(1:length(data.Year),1) = Ustar_th;
    else
        data.Ustar_th = Ustar_th;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% &&&&&&&&&&&&&&&&&& MAIN SECTION &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%%% Relationship for Respiration (i.e. Nighttime and Non-Growing Season)
% ind_param_RE = find((data.Ustar >= data.Ustar_th & ~isnan(data.Ts5) & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
%     (data.Ustar >= data.Ustar_th & ~isnan(data.NEE) & data.Ts5 < -1  ) );                                   % non-growing season
ind_param_RE = find(data.Ustar >= data.Ustar_th & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE));
X_in = [data.Ts5(ind_param_RE) data.SM_a(ind_param_RE) data.PAR(ind_param_RE)];
Y_in = data.NEE(ind_param_RE);
stdev_in = ones(length(X_in),1);
%%% Replaced data.SM with NaNs... not needed
X_eval = [data.Ts5 NaN.*ones(length(data.Ts5),1) data.PAR];

options.costfun ='OLS'; options.min_method ='NM'; options.f_coeff = [NaN NaN NaN];
[c_hat_RE, y_hat_RE, pred_RE, stats_RE, sigma_RE, err_RE, exitflag_RE, num_iter_RE] = ...
    fitresp([9 0.2 12], 'fitresp_2A', X_in, Y_in, X_eval, stdev_in, options);

%%% In this version, we'll try and just use model residuals to give us an
%%% idea of the spread of the data:
error_RE = Y_in - y_hat_RE;

if plot_flag == 1
    %%% First plot will show historgrams for error for both RE and GEP:
    figure('Name', 'Error Distribution - RE, GEP','Tag','v5_Err_Dist');clf
    subplot(211)
    %%% Create histogram of error to check distribution:
    [y_RE xout_RE] = hist(error_RE,100);
    bar(xout_RE,y_RE)
    ylabel('count');
    xlabel('Error Bins');
    title('RE');
    
    %%% Second plot will show scatter of error as function of modeled RE, GEP:
    figure('Name', 'Error vs. RE, GEP', 'Tag', 'v5_Err_Scatter');clf
    %%% Create scatterplot -- let's see if data is homoscedastic:
    h1(1) = plot(y_hat_RE, error_RE,'r.'); hold on;
    xlabel('Predicted RE, GEP value');
    ylabel('Error');
    % axis([0 40 -10 10]);
end

%% Calculate GEP from NEE and R:
GEPraw = pred_RE - data.NEE;
% flag_gs = zeros(length(GEPraw),1); % variable to keep track of what is growing season and what isn't

%%% Model GEP based on PAR, Ts, Ta, VPD,
% ind_param_GEP = find(data.Ts5 >= -1 & data.VPD > 0 & data.Ta > -5 & data.PAR > 20 & ~isnan(GEPraw) & data.Ustar > data.Ustar_th ...
%     & data.dt > 95 & data.dt < 325 & data.GDD > 8);
        ind_param_GEP = find(~isnan(GEPraw.*data.Ts5.*data.PAR) & data.GEP_flag==2 & data.VPD > 0 & data.Ustar > data.Ustar_th);      

options.costfun ='OLS'; options.min_method ='NM'; options.f_coeff = NaN.*ones(1,6);
[junk1, y_hat_GEPL6, pred_GEPL6, junk1 junk3, junk4, junk5, junk6] = ...
    fitGEP([0.05 35 2 4 -2 -0.8], 'fitGEP_1H1_2L6', [data.PAR(ind_param_GEP) data.Ts5(ind_param_GEP) data.VPD(ind_param_GEP)], ...
    GEPraw(ind_param_GEP), [data.PAR data.Ts5 data.VPD], [], options);

% ind_GEP = find(data.PAR >= 20 & ((data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%     | data.dt > 330 & data.Ts5 >= 1.25 & data.Ta > 2));
        ind_GEP = find(data.GEP_flag>=1);
% ind_gs =  (data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%     | (data.dt > 330 & data.Ts5 >= 1.25 & data.Ta > 2) ;
% flag_gs(ind_gs==1,1) = 1;
clear junk;
pred_GEP(1:length(data.Year),1)= 0;
pred_GEP(ind_GEP,1) = pred_GEPL6(ind_GEP,1);

%%% Error in GEP prediction
error_GEP = GEPraw(ind_param_GEP) - y_hat_GEPL6;

if plot_flag == 1
    % figure('Name', 'Error Distribution - GEP')
    figure(findobj('Tag','v5_Err_Dist'));
    subplot(212)
    %%% Create histogram of error to check distribution:
    [y_GEP xout_GEP] = hist(error_GEP,100);
    bar(xout_GEP,y_GEP)
    ylabel('count');
    xlabel('Error Bins');
    title('GEP');
    
    figure(findobj('Tag','v5_Err_Scatter'));
    %%% Create scatterplot -- let's see if data is homoscedastic:
    h1(2) = plot(y_hat_GEPL6, error_GEP,'b.');
    xlabel('Predicted GEP value');
    ylabel('Error');
    axis([0 40 -10 10]);
    legend(h1,'RE','GEP');
end

%% ***********************************************************************
%%% This is where we diverge from previous versions -- instead of using GEP
%%% and RE as analogs for +/- NEE, we'll instead derive modeled NEE and use
%%% that to find the error directly in measured NEE:

NEE_model = pred_RE - pred_GEP;

ind_comp_RE = find(~isnan(data.NEE.*NEE_model) & pred_GEP == 0 & data.Ustar > data.Ustar_th); 
Error_NEE_RE = NEE_model(ind_comp_RE) - data.NEE(ind_comp_RE);

ind_comp_GEP = find(~isnan(data.NEE.*NEE_model) & pred_GEP > 0); 
Error_NEE_GEP = NEE_model(ind_comp_GEP) - data.NEE(ind_comp_GEP);

PAR_RE = data.PAR(ind_comp_RE);
PAR_GEP = data.PAR(ind_comp_GEP);
Ts_RE = data.Ts5(ind_comp_RE);
Ts_GEP = data.Ts5(ind_comp_GEP);
% 
Error_all = [Error_NEE_RE; Error_NEE_GEP];
PAR_all = [PAR_RE; PAR_GEP];
Ts_all = [Ts_RE; Ts_GEP];


%% &&&&&&&&&&&&&&&&&&&&&&&& NEW &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%%% Here we will try and do double bin-average error by PAR and Ts
clear num_pts Error_std Ts_mid PAR_mid

%%% Added Dec 8, 2010 byJJB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Is there any way that we can have the program figure out what is the
%%% best interval to use?
%%% Idea 1: Keep the low and high bounds, and just alter the interval?
%%% Perhaps we can sort the values and set the bins so that each bin has
%%% 100 (or 200) points in each bin.
%%%% Will work on this later... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Right now, stick with consistent bin sizes:
PAR_bins = [0 20 100:150:2200 3000]';
Ts_bins = [-20 -6:1.5:22 26]';
%%% Rows are Ts Bins
%%% Columns are PAR Bins 
for i_Ts = 1:1:length(Ts_bins)-1
    
   for i_PAR =  1:1:length(PAR_bins)-1
       ind = find(PAR_all >= PAR_bins(i_PAR) & PAR_all < PAR_bins(i_PAR+1) ...
           & Ts_all >= Ts_bins(i_Ts) & Ts_all < Ts_bins(i_Ts+1));
    num_pts(i_Ts,i_PAR) = length(ind);
    Error_std(i_Ts,i_PAR) = std(Error_all(ind,1));
    Ts_mid(i_Ts,i_PAR) = median(Ts_all(ind));
    PAR_mid(i_Ts,i_PAR) = median(PAR_all(ind));
    
    clear ind;
   end
end
PAR_plot = PAR_mid(:);
Ts_plot = Ts_mid(:);
std_plot = Error_std(:);
num_pts = num_pts(:);
ind_plot = find(~isnan(PAR_plot.*Ts_plot.*std_plot)& num_pts > 30);
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

%%% Fit a Linear 2-D regression to the data in Ts and PAR dimensions:
polymodel = polyfitn([Ts_plot(ind_plot) PAR_plot(ind_plot)],std_plot(ind_plot),[0 0; 1 0; 0 1]);
coeff = polymodel.Coefficients;
std_est = coeff(1) + Ts_plot.*coeff(2) + PAR_plot.*coeff(3);
std_mesh = reshape(std_est,size(Ts_mid,1),[]);

% if plot_flag == 1
    f_fit = figure('Name', 'std vs. Ts, PAR') ;clf
    plot3(Ts_plot(ind_plot),PAR_plot(ind_plot),std_plot(ind_plot),'o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',4);
    hold on; grid on;
    mesh(Ts_mid,PAR_mid,std_mesh);
    axis([-5 25 0 2500 0 8])
    title('std vs. Ts, PAR');
    zlabel('\sigma_{NEE}');
    ylabel('PAR - binned');
    xlabel('Ts - binned');
% end

%% Predict std for every data point:
std_pred = coeff(1) + data.Ts5.*coeff(2) + data.PAR.*coeff(3);
std_pred(std_pred < 0.5) = 0.5;
% if plot_flag == 1;
    f_std = figure('Name','Predicted Std');
    plot(std_pred); 
    ylabel('Predicted \sigma_{NEE}');
    title('Predicted \sigma_{NEE}');
% end

if ~isempty(find(isnan(std_pred), 1))==1
    disp(['number of nans in predicted std = ' num2str(length(find(isnan(std_pred))))]);
end

