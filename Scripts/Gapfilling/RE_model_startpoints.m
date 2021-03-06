%%% Testing approximate starting points for various Respiration Models:
clear all;
close all;
Ustar_th = 0.325;
site = 'TP39';
year_start = 2003; year_end = 2009;
%%% Paths:
ls = addpath_loadstart;
load_path = [ls 'Matlab/Data/Master_Files/' site '/'];
save_path = [ls 'Matlab/Data/Flux/CPEC/' site '/Final_Calculated/'];
footprint_path = [ls 'Matlab/Data/Flux/Footprint/'];

%%% Load gapfilling file and make appropriate adjustments:
load([load_path site '_gapfill_data_in.mat']);
%%% trim data to fit with the years selected:
data = trim_data_files(data,year_start, year_end);
%%% Calculate VPD from RH and Ta:
data.VPD = VPD_calc(data.RH, data.Ta);
[~, data.GDD] = GDD_calc(data.Ta,10,48,year_start:1:year_end);
data.SM = data.SM_a_filled; %clear SM;
%%% Add a tag for the site name:
data.site = site;
data.NEEstd = NEE_random_error_estimator(data, [], Ustar_th);
close all;
% options.costfun = {'WSS';'OLS';'MAWE'};
% options.min_method = {'NM';'LM'};
% %%% Respiration Options:
% options.RE.model = {'fitresp_1A'; 'fitresp_1B'; 'fitresp_2A'; 'fitresp_2B'; ...
%     'fitresp_3A'; 'fitresp_3B'; 'fitresp_3C'; 'fitresp_7A'};

%% fitresp_1A - L&T
% Look to Richardson et al (2007) for possible starting points
options.fitresp_1A.coeff0 = [60 68 259];
options.fitresp_1A.range = [40 40 40];
c_hat_array = [];
stats_array = [];
err_array = [];
exitflag_array = [];
num_iter_array = [];
y_hat_array = [];

ind_param(1).RE_all = find((data.Ustar >= Ustar_th & ~isnan(data.Ts5) & ~isnan(data.SM) & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
        (data.Ustar >= Ustar_th & ~isnan(data.NEE) & ~isnan(data.SM) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );                                   % non-growing season
% 30 different realizations of starting coefficients:
r = 2.*rand(30,3)-1;
for i = 1:1:size(r,1)
coeff_in(i,1:3) = options.fitresp_1A.coeff0 + r(i,1:3).* options.fitresp_1A.range;

    options.costfun ='WSS'; options.min_method ='NM';
[c_hat(i).RE1all, y_hat(i).RE1all, y_pred(i).RE1all, stats(i).RE1all, sigma(i).RE1all, err(i).RE1all, exitflag(i).RE1all, num_iter(i).RE1all] = ...
    fitresp(coeff_in(i,1:end), 'fitresp_1A', [data.Ts5(ind_param(1).RE_all) data.SM(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM], data.NEEstd(ind_param(1).RE_all), options);

c_hat_array = [c_hat_array; c_hat(i).RE1all];
stats_array = [stats_array; stats(i).RE1all.RMSE stats(i).RE1all.MAE stats(i).RE1all.BE stats(i).RE1all.R2];
err_array = [err_array; err(i).RE1all];
exitflag_array = [exitflag_array; exitflag(i).RE1all];
num_iter_array = [num_iter_array; num_iter(i).RE1all];
y_hat_array = [y_hat_array y_hat(i).RE1all];

total_dev_tmp(i,:) = options.fitresp_1A.coeff0 - coeff_in(i,:);
total_dev(i,1) = sum(abs(total_dev_tmp(i,:)));
end

figure(1);clf;
ind_plot = find(exitflag_array(:,1) == 1);
plot(data.NEE(ind_param(1).RE_all));hold on;
plot(y_hat_array(:,ind_plot(1:5)))

figure(2);clf;
for i = 1:1:length(ind_plot)
    plot3([coeff_in(ind_plot(i),1) c_hat_array(ind_plot(i),1)],[coeff_in(ind_plot(i),2) c_hat_array(ind_plot(i),2)],...
        [coeff_in(ind_plot(i),3) c_hat_array(ind_plot(i),3)],'k-'); hold on;
    plot3(c_hat_array(ind_plot(i),1), c_hat_array(ind_plot(i),2), c_hat_array(ind_plot(i),3),'b.'); hold on;
    plot3(coeff_in(ind_plot(i),1), coeff_in(ind_plot(i),2), coeff_in(ind_plot(i),3),'ro'); 
end
grid on;

%% fitresp_1B - L&T (Ts+SM)
% Look to Richardson et al (2007) for possible starting points
%%% Clear existing values
clear coeff_in c_hat y_pred y_hat stats sigma err exitflag num_iter total_dev* ind_param
c_hat_array = [];stats_array = [];err_array = [];
exitflag_array = [];num_iter_array = [];y_hat_array = [];
clrs = [1 0 0; 0 1 0; 0 0 1; 0.2 0.4 0.7; 0.7 0.7 0.7];
%%% Set Mix and Max values for coefficient range:
options.fitresp_1B.cmin = [40 40 100 0.1 5];
options.fitresp_1B.cmax = [1500 800 300 20 300];
num_coeffs = 5;
num_runs = 100;
coeff_in = NaN.*ones(num_runs,num_coeffs);
%%% Find datapoints that can be used for parameterization:
ind_param(1).RE_all = find((data.Ustar >= Ustar_th & ~isnan(data.Ts5) & ~isnan(data.SM) & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
        (data.Ustar >= Ustar_th & ~isnan(data.NEE) & ~isnan(data.SM) & ~isnan(data.Ts5) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );                                   % non-growing season
% Produce stats to use when making starting coefficient realizations:
options.fitresp_1B.cmids = mean([options.fitresp_1B.cmin; options.fitresp_1B.cmax]);
options.fitresp_1B.crange = options.fitresp_1B.cmax - options.fitresp_1B.cmids;
r = 2.*rand(num_runs,num_coeffs)-1;

tic;
for i = 1:1:size(r,1)
    if rem(i,5)==0
        t = toc;
        disp(['Now running loop ' num2str(i) ' after ' num2str(t) ' seconds.']);
    end
% Assign numbers for starting coefficients for loop #i
coeff_in(i,1:num_coeffs) = options.fitresp_1B.cmids + r(i,1:num_coeffs).* options.fitresp_1B.crange;
% Run minimization:
    options.costfun ='WSS'; options.min_method ='NM';
[c_hat.RE1all, y_hat.RE1all, y_pred.RE1all, stats.RE1all, sigma.RE1all, err.RE1all, exitflag.RE1all, num_iter.RE1all] = ...
    fitresp(coeff_in(i,1:end), 'fitresp_1B', [data.Ts5(ind_param(1).RE_all) data.SM(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM], data.NEEstd(ind_param(1).RE_all), options);
% Assign values to data arrays we are keeping:
c_hat_array = [c_hat_array; c_hat.RE1all];
stats_array = [stats_array; stats.RE1all.RMSE stats.RE1all.MAE stats.RE1all.BE stats.RE1all.R2];
err_array = [err_array; err.RE1all];
exitflag_array = [exitflag_array; exitflag.RE1all];
num_iter_array = [num_iter_array; num_iter.RE1all];
y_hat_array = [y_hat_array y_hat.RE1all];
total_dev_tmp(i,:) = options.fitresp_1B.cmids - coeff_in(i,:);
total_dev(i,1) = sum(abs(total_dev_tmp(i,:)));
clear c_hat stats err exitflag num_iter y_hat y_pred;
end
%%% Find the runs that had the best values for each statistic of interest:
ind_best.RMSE = find(stats_array(:,1) == min(stats_array(:,1)));
ind_best.MAE = find(stats_array(:,2) == min(stats_array(:,2)));
ind_best.BE = find(abs(stats_array(:,3)) == min(abs(stats_array(:,3))));
ind_best.R2 = find(stats_array(:,4) == max(stats_array(:,4)));
%%% hp tells the SWC at which the SM scaling function will = 50%
hp = c_hat_array(:,4)./c_hat_array(:,5);

%%% Figure 1: Plot the Raw data along with the best estimates
if ~isempty(findobj('Tag','Raw+Est')) 
    figure(findobj('Tag','Raw+Est'));clf;
else
figure('Tag','Raw+Est','Name','Raw RE + best-estimates');
end
figure(findobj('Tag','Raw+Est'));clf;
ind_plot = [ind_best.RMSE; ind_best.MAE; ind_best.BE; ind_best.R2];
plot(data.NEE(ind_param(1).RE_all),'Color',[0.6 0.6 0.6]);hold on;
plot(y_hat_array(:,ind_plot))
legend('raw','RMSE','MAE','BE','R2')

%%% Figure 2: Plot starting and ending coefficient values:
if ~isempty(findobj('Tag','Coeffs')) 
figure(findobj('Tag','Coeffs'));clf;
else
figure('Tag','Coeffs','Name','Coeffs-Start+End');
end
for i = 1:1:size(r,1)
    if exitflag_array(i,1) == 1
    plot3([coeff_in(i,1) c_hat_array(i,1)],[coeff_in(i,2) c_hat_array(i,2)],...
        [coeff_in(i,3) c_hat_array(i,3)],'k-'); hold on;
    plot3(c_hat_array(i,1), c_hat_array(i,2), c_hat_array(i,3),'b.'); hold on;
    plot3(coeff_in(i,1), coeff_in(i,2), coeff_in(i,3),'ro'); 
    else
    plot3(coeff_in(i,1), coeff_in(i,2), coeff_in(i,3),'ro','MarkerSize',8,'MarkerFaceColor','k'); 
    
    end
end
h1(1) = plot3(c_hat_array(ind_best.RMSE,1), c_hat_array(ind_best.RMSE,2), c_hat_array(ind_best.RMSE,3),'gs','MarkerSize',12); hold on;
h1(2) = plot3(c_hat_array(ind_best.BE,1), c_hat_array(ind_best.BE,2), c_hat_array(ind_best.BE,3),'cs','MarkerSize',12); hold on;
h1(3) = plot3(c_hat_array(ind_best.R2,1), c_hat_array(ind_best.R2,2), c_hat_array(ind_best.R2,3),'mo','MarkerSize',16); hold on;
legend(h1,{'RMSE','BE','R2'})
xlabel('coeff 1');
ylabel('coeff 2');
zlabel('coeff 3');
axis([0 10000 0 1000 0 500])
grid on;

%%% Figure 3: Plot the starting points for all variables.  Point out values
%%% at which parameterization failed.
if ~isempty(findobj('Tag','Coeff_in')) 
    figure(findobj('Tag','Coeff_in'));clf;
else
figure('Tag','Coeff_in','Name','Coeff_in');
end
ind_bad = find(exitflag_array==0);
kk = coeff_in(ind_bad,:);
for k = 1:1:size(coeff_in,2)
h(k) = plot(coeff_in(:,k),'.-','Color',clrs(k,:)); hold on
plot(ind_bad,kk(:,k),'o','Color',clrs(k,:))
end
legend(h,{'coeff1';'coeff2';'coeff3';'coeff4';'coeff5'});
clear ind_bad kk;

%%% Figure 4: Plot starting and ending coefficient values for SM:
if ~isempty(findobj('Tag','SM-Coeffs')) 
figure(findobj('Tag','SM-Coeffs'));clf;
else
figure('Tag','SM-Coeffs','Name','SM-Coeffs-Start+End');
end
for i = 1:1:size(r,1)
    if exitflag_array(i,1) == 1
    plot([coeff_in(i,4) c_hat_array(i,4)],[coeff_in(i,5) c_hat_array(i,5)],'k-'); hold on;
    plot(c_hat_array(i,4), c_hat_array(i,5),'b.'); hold on;
    plot(coeff_in(i,4), coeff_in(i,5),'ro'); 
    else
    plot(coeff_in(i,4), coeff_in(i,5),'ro','MarkerSize',8,'MarkerFaceColor','k'); 
    
    end
end
h1(1) = plot(c_hat_array(ind_best.RMSE,4), c_hat_array(ind_best.RMSE,5),'gs','MarkerSize',12); hold on;
h1(2) = plot(c_hat_array(ind_best.BE,4), c_hat_array(ind_best.BE,5),'cs','MarkerSize',12); hold on;
h1(3) = plot(c_hat_array(ind_best.R2,4), c_hat_array(ind_best.R2,5),'mo','MarkerSize',16); hold on;
% Plot the line separating meaningful/non-meaningful values:
xlabel('coeff 1');
ylabel('coeff 2');
% Run function to get information on the nature of SM coefficients
ok_flag = find_ok_SM_coeffs(c_hat_array(:,4:5));
% Meaning of flags:
% 0: function decreases
% 1: function pases -- appears good
% 2: function does not top out at high SM
% -1: function serves no purpose(tops out before reaching meaningful SM
% axis([0 10000 0 1000 0 500])
ind_m1 = find(ok_flag==-1);
h1(4) = plot(c_hat_array(ind_m1,4), c_hat_array(ind_m1,5),'o','Color','k','MarkerFaceColor',[0.2 0.8 0.5],'MarkerSize',10); hold on;
ind_2 = find(ok_flag==2);
h1(5) = plot(c_hat_array(ind_2,4), c_hat_array(ind_2,5),'o','Color','k','MarkerFaceColor',[0.9 0.3 0.1],'MarkerSize',10); hold on;
legend(h1,{'RMSE','BE','R2','no-use','no-top'})
grid on;

%%% Saving final output data:
output.c_hat_array = c_hat_array;
output.stats_array = stats_array;
output.err_array = err_array;
output.exitflag_array = exitflag_array;
output.num_iter_array = num_iter_array;
output.y_hat_array = y_hat_array;
output.total_dev = total_dev;

%% fitresp_2A - Logi (Ts)
clear coeff_in c_hat y_pred y_hat stats sigma err exitflag num_iter total_dev* ind_param
options.fitresp_2A.coeff0 = [10 0.2 12];
options.fitresp_2A.range = [10 0.2 10];
num_coeffs = 3;
c_hat_array = [];
stats_array = [];
err_array = [];
exitflag_array = [];
num_iter_array = [];
y_hat_array = [];

ind_param(1).RE_all = find((data.Ustar >= Ustar_th & ~isnan(data.Ts5) & ~isnan(data.SM) & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
        (data.Ustar >= Ustar_th & ~isnan(data.NEE) & ~isnan(data.SM) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );                                   % non-growing season
% 30 different realizations of starting coefficients:
r = 2.*rand(30,num_coeffs)-1;
tic;
for i = 1:1:size(r,1)
    if rem(i,5)==0
        t = toc;
        disp(['Now running loop ' num2str(i) ' after ' num2str(t) ' seconds.']);
    end
coeff_in(i,1:num_coeffs) = options.fitresp_2A.coeff0 + r(i,1:num_coeffs).* options.fitresp_2A.range;

    options.costfun ='WSS'; options.min_method ='NM';
[c_hat(i).RE1all, y_hat(i).RE1all, y_pred(i).RE1all, stats(i).RE1all, sigma(i).RE1all, err(i).RE1all, exitflag(i).RE1all, num_iter(i).RE1all] = ...
    fitresp(coeff_in(i,1:end), 'fitresp_2A', [data.Ts5(ind_param(1).RE_all) data.SM(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM], data.NEEstd(ind_param(1).RE_all), options);

c_hat_array = [c_hat_array; c_hat(i).RE1all];
stats_array = [stats_array; stats(i).RE1all.RMSE stats(i).RE1all.MAE stats(i).RE1all.BE stats(i).RE1all.R2];
err_array = [err_array; err(i).RE1all];
exitflag_array = [exitflag_array; exitflag(i).RE1all];
num_iter_array = [num_iter_array; num_iter(i).RE1all];
y_hat_array = [y_hat_array y_hat(i).RE1all];

total_dev_tmp(i,:) = options.fitresp_2A.coeff0 - coeff_in(i,:);
total_dev(i,1) = sum(abs(total_dev_tmp(i,:)));
end

figure(1);clf;
ind_plot = find(exitflag_array(:,1) == 1);
plot(data.NEE(ind_param(1).RE_all));hold on;
plot(y_hat_array(:,ind_plot(1:5)))

figure(2);clf;
for i = 1:1:length(ind_plot)
    plot3([coeff_in(ind_plot(i),1) c_hat_array(ind_plot(i),1)],[coeff_in(ind_plot(i),2) c_hat_array(ind_plot(i),2)],...
        [coeff_in(ind_plot(i),3) c_hat_array(ind_plot(i),3)],'k-'); hold on;
    plot3(c_hat_array(ind_plot(i),1), c_hat_array(ind_plot(i),2), c_hat_array(ind_plot(i),3),'b.'); hold on;
    plot3(coeff_in(ind_plot(i),1), coeff_in(ind_plot(i),2), coeff_in(ind_plot(i),3),'ro'); 
end
grid on;
axis([5 15 0 0.3 10 20])

%% fitresp_2B - Logi (Ts+SM)
clear coeff_in c_hat y_pred y_hat stats sigma err exitflag num_iter total_dev* ind_param
options.fitresp_2B.coeff0 = [10 0.2 12 10 200];
options.fitresp_2B.range = [10 0.2 10 10 50];
num_coeffs = 5;
c_hat_array = [];
stats_array = [];
err_array = [];
exitflag_array = [];
num_iter_array = [];
y_hat_array = [];

ind_param(1).RE_all = find((data.Ustar >= Ustar_th & ~isnan(data.Ts5) & ~isnan(data.SM) & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
        (data.Ustar >= Ustar_th & ~isnan(data.NEE) & ~isnan(data.SM) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );                                   % non-growing season
% 30 different realizations of starting coefficients:
r = 2.*rand(30,num_coeffs)-1;
tic;
for i = 1:1:size(r,1)
    if rem(i,5)==0
        t = toc;
        disp(['Now running loop ' num2str(i) ' after ' num2str(t) ' seconds.']);
    end
coeff_in(i,1:num_coeffs) = options.fitresp_2B.coeff0 + r(i,1:num_coeffs).* options.fitresp_2B.range;

    options.costfun ='WSS'; options.min_method ='NM';
[c_hat(i).RE1all, y_hat(i).RE1all, y_pred(i).RE1all, stats(i).RE1all, sigma(i).RE1all, err(i).RE1all, exitflag(i).RE1all, num_iter(i).RE1all] = ...
    fitresp(coeff_in(i,1:end), 'fitresp_2B', [data.Ts5(ind_param(1).RE_all) data.SM(ind_param(1).RE_all)] , data.NEE(ind_param(1).RE_all), [data.Ts5 data.SM], data.NEEstd(ind_param(1).RE_all), options);

c_hat_array = [c_hat_array; c_hat(i).RE1all];
stats_array = [stats_array; stats(i).RE1all.RMSE stats(i).RE1all.MAE stats(i).RE1all.BE stats(i).RE1all.R2];
err_array = [err_array; err(i).RE1all];
exitflag_array = [exitflag_array; exitflag(i).RE1all];
num_iter_array = [num_iter_array; num_iter(i).RE1all];
y_hat_array = [y_hat_array y_hat(i).RE1all];

total_dev_tmp(i,:) = options.fitresp_2B.coeff0 - coeff_in(i,:);
total_dev(i,1) = sum(abs(total_dev_tmp(i,:)));
end

figure(1);clf;
ind_plot = find(exitflag_array(:,1) == 1);
plot(data.NEE(ind_param(1).RE_all));hold on;
plot(y_hat_array(:,ind_plot(1:5)))

figure(2);clf;
for i = 1:1:length(ind_plot)
    plot3([coeff_in(ind_plot(i),1) c_hat_array(ind_plot(i),1)],[coeff_in(ind_plot(i),2) c_hat_array(ind_plot(i),2)],...
        [coeff_in(ind_plot(i),3) c_hat_array(ind_plot(i),3)],'k-'); hold on;
    plot3(c_hat_array(ind_plot(i),1), c_hat_array(ind_plot(i),2), c_hat_array(ind_plot(i),3),'b.'); hold on;
    plot3(coeff_in(ind_plot(i),1), coeff_in(ind_plot(i),2), coeff_in(ind_plot(i),3),'ro'); 
end
grid on;
axis([5 50 0 0.3 10 20])
hp = c_hat_array(:,4)./c_hat_array(:,5);


