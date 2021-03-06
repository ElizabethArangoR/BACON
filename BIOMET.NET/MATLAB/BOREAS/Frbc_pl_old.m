function [t,x] = frbc_pl(ind, year, fig_num_inc,pause_flag)
%
% [t,x] = frbc_pl(ind, year, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       Jul  8, 1997
%                           Last modification:  Jan 31, 2001
%

% Revisions:
%   
% Feb 1, 2001
%   - added gashound data trace, fixed up fr_c traces
% Jan 31, 2001
%   - changed some axes, added Gen-ON plots, changed the way Gen-Run-Time is
%     calculated (this time this is 100% accurate, AC sensing circuit is used)
% Jan 15, 2001
%   - changed some paths
% Jul 22, 2000
%   - removed a few graphs, adjusted some axes...
% Jun 27, 2000
%   - added a correction for the third Net and one extra 1:1 plot
% Jun 1, 2000
%   - added Net 1:1 plot
%
% Dec 30 ,1999
%   - changes in biomet_path calling syntax.
% Nov 21, 1999
%   - added estimation of N2 usage (kPa/Week)
%   Nov 14, 1999
%       - changed plotting of the closure graphs. Now the program does NOT
%         remove trailing and leading zeros before plotting (added ",0" in
%         read_sig(...) )
%   September 02, 1999
%       - added third R.M. Young at 3.5-m height
%   May 15, 1999
%       - introduced global paths (file biomet_path.m), removed LOCAL_PATH variable
%       - adjusted a few axes
%   March 24, 1999
%       - added dave datalogger battery voltage on separate fig with uvic voltage
%       - indicated HMP location and shield in figure legend
%   March 22, 1999
%       - added throughfall data (throughs only) from 'dave' datalogger
%   Feb 7, 1999
%       - fixed cumulative rain plotting for year!=1998 (offset adding removed
%         if year!=1998) for the second gauge.
%   Jan 1, 1999
%       - changes to alow for the new year (1999). The changes enabled
%         automatic handling of the "year" parameter.
%   Nov 6, 1998
%       - added RM Young at 3.5 m
%       Oct 30, 1998
%           - uvic_01 battery voltage, sap flow gauges and more tree thermocouples
%       Oct 14, 1998
%           - introduced WINTER_TEMP_OFFSET for easy rescaling of temperature axes
%             in the program
%       Aug 19, 1998
%           - Rick added new net, PSP, PAR, Soil Temps
%       June 9, 1998
%           -   added charging current plots

% More revisions at the end of the file
%

WINTER_TEMP_OFFSET = 0;
colordef none

if nargin < 4
    pause_flag = 0;
end
if nargin < 3
    fig_num_inc = 1;
end
if nargin < 2 | isempty(year)
    year = datevec(now);                    % if parameter "year" not given
    year = year(1);                         % assume current year
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 8/24;                                    % offset to convert GMT to PST
if year >= 1996
    [pth] = biomet_path(year,'CR','cl');            % get the climate data path
    %if LOCAL_PATH == 1
    %    pth = 'd:\local_dbase\';
    %else
    %    pth = '\\class\paoa\newdata\';
    %end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

t=read_bor([ pth 'fr_a\fr_a_dt']);                  % get decimal time from the data base
if year < 2000
    offset_doy=datenum(year,1,1)-datenum(1996,1,1);     % find offset DOY
else
    offset_doy=0;
end
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

if 1==1
%----------------------------------------------------------
% Battery voltage
%----------------------------------------------------------
%trace_name  = 'Battery voltage';
%trace_path  = str2mat([pth 'fr_a\fr_a.5'],[pth 'fr_a\fr_a.6'],[pth 'fr_a\fr_a.8'],[pth 'fr_e\fr_e.5'],[pth 'fr_a\fr_a.46'],[pth 'fr_e\fr_e.5'],[pth 'fr_d\fr_d.5']);
%trace_legend = str2mat('fr\_a Avg','fr\_a Max','fr\_a Min','fr\_e Avg','BB#2-0.3V','Gen.Hut','fr\_d Avg');
%trace_units = '(V)';
%y_axis      = [10 15];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
trace_name  = 'HMP air temperature';
trace_path  = str2mat([pth 'fr_a\fr_a.17'],[pth 'fr_a\fr_a.75'],[pth 'fr_a\fr_a.85']);
trace_legend = str2mat('HMP\_27m Gill','HMP\_41m Met-1','HMP\_4m Met-1');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery voltage 1
%----------------------------------------------------------
trace_name  = 'Battery voltage 1';
trace_path  = str2mat([pth 'fr_a\fr_a.5'],[pth 'fr_a\fr_a.6'],[pth 'fr_a\fr_a.8']);
trace_legend = str2mat('fr\_a Avg','fr\_a Max','fr\_a Min');
trace_units = '(V)';
y_axis      = [11.5 13.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery voltage 2
%----------------------------------------------------------
trace_name  = 'Battery voltage 2';
trace_path  = str2mat([pth 'fr_a\fr_a.5'],[pth 'fr_d\fr_d.5'],[pth 'fr_f\fr_f.5'],[pth 'fr_a\fr_a.46']);
trace_legend = str2mat('fr\_a Avg','fr\_d Avg','fr\_f Avg','BB#2-0.3V');
trace_units = '(V)';
y_axis      = [10.5 14.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Battery voltage 3
%----------------------------------------------------------
trace_name  = 'Battery voltage 3';
trace_path  = str2mat([pth 'uvic_01\uv01a.5'], [pth 'dave\dave1.17']);
trace_legend = str2mat('UVic\_01 Avg', 'Dave Avg');
trace_units = '(V)';
y_axis      = [11 14];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% BB voltages
%----------------------------------------------------------
trace_name  = 'BB voltages';
trace_path  = str2mat([pth 'fr_d\fr_d.6'],[pth 'fr_d\fr_d.7']);
trace_legend = str2mat('BB #1','BB #2');
trace_units = '(V)';
y_axis      = [10.5 14.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

v = read_bor([pth 'fr_d\fr_d.16']);
h  = get(fig_num,'child');
for i = 1:length(h)
    junk = get(h(i),'tag');
    if strcmp(junk,''); break;end
end
axes(h(i))
ax = axis;
text((ax(2)-ax(1))*.1 + ax(1), 11.2, sprintf('Gen.run-time for this period = %5.1f hours',sum(v(ind))/2));
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Generator ON
%----------------------------------------------------------
trace_name  = 'Generator ON';
trace_path = read_sig( [pth 'fr_d\fr_d.16'], ind,year, t, 0 );
trace_legend = [];
trace_units = '1';
y_axis      = [0 1.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

h  = get(fig_num,'child');
for i = 1:length(h)
    junk = get(h(i),'tag');
    if strcmp(junk,''); break;end
end
axes(h(i))
ax = axis;
text((ax(2)-ax(1))*.1 + ax(1), 1.3, ...
    sprintf('Gen.run-time for this period = %5.1f hours or %5.1f hours per day.', ...
    sum(trace_path)/2,sum(trace_path)/2/(length(trace_path)/48)));
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Generator daily run-time 
%----------------------------------------------------------
trace_name  = 'Generator daily run-time';
x = read_sig( [pth 'fr_d\fr_d.16'], ind,year, t, 0 );
X=cumsum(x)/2;
trace_path = [X(48) ;X(49:48:end)-X(1:48:end-48)];
t_new = t(1:48:end);
trace_legend = [];
trace_units = 'hours/day';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t_new, fig_num );


%----------------------------------------------------------
% BB currents
%----------------------------------------------------------
trace_name  = 'BB currents';
trace_path  = str2mat([pth 'fr_d\fr_d.8'],[pth 'fr_d\fr_d.9']);
trace_legend = str2mat('BB #1','BB #2');
trace_units = '(A)';
y_axis      = [2 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
hold on
currentTotal = sum(x');
[currentTotal,indx] = del_num(currentTotal,0,2);      % remove leading and trailing zeros from x
plot(t(indx), currentTotal,'g')
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Power consumption
%----------------------------------------------------------
trace_name  = 'Power consumption';
Ibb1 = read_sig( [pth 'fr_d\fr_d.8'], ind,year, t, 0 );
Ibb2 = read_sig( [pth 'fr_d\fr_d.9'], ind,year, t, 0 );
BB2  = read_sig( [pth 'fr_d\fr_d.7'], ind,year, t, 0 );
trace_path  = (Ibb1 + Ibb2) .* BB2;
trace_legend = [];
trace_units = '(W)';
y_axis      = [200 300];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Charging currents
%----------------------------------------------------------
trace_name  = 'Charging Currents';
trace_path  = str2mat([pth 'fr_d\fr_d.10'],[pth 'fr_d\fr_d.11']);
trace_legend = str2mat('BB #1','BB #2');
trace_units = '(A)';
y_axis      = [0 100];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Panel temperatures
%----------------------------------------------------------
trace_name  = 'Panel temperatures';
trace_path  = str2mat([pth 'fr_a\fr_a.11'],[pth 'fr_a\fr_a.12'],[pth 'fr_a\fr_a.14'],[pth 'fr_a\fr_a.50'],[pth 'fr_b\fr_b.11']);
trace_legend = str2mat('fr\_a T1 Avg','fr\_a T1 Max','fr\_a T1 Min','fr\_a T3 Avg','fr\_b T');
trace_units = '(degC)';
y_axis      = [10 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Tank Pressures
%----------------------------------------------------------
trace_name  = 'Tank Pressures';
trace_path  = str2mat([pth 'fr_a\fr_a.66'],[pth 'fr_a\fr_a.67'],[pth 'fr_a\fr_a.68'],[pth 'fr_a\fr_a.69']);
trace_legend = str2mat('Ref','Zero','335','445');
trace_units = '(psi)';
y_axis      = [0 2600];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
x=x_all(:,1);
ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Rate of change = %4.0f kPa per week',perWeek));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Low limit(%5.1f) will be reached on DOY = %4.0f',ref_lim,lowLim));
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow temperatures 
%----------------------------------------------------------
trace_name  = 'Snow temperatures';
trace_path  = str2mat([pth 'fr_a\fr_a.70'],[pth 'fr_a\fr_a.71'],[pth 'fr_a\fr_a.72'],[pth 'fr_a\fr_a.73'],[pth 'fr_a\fr_a.74']);
trace_legend = str2mat('Snow 1 cm','Snow 5 cm','Snow 10 cm','Snow 20 cm','Snow 50 cm');
trace_units = '(degC)';
y_axis      = [0 30] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Soil Temperatures
%-----------------------------------
trace_name  = 'Soil Temperatures ';
trace_path  = str2mat([pth 'fr_a\fr_a.54'],[pth 'fr_a\fr_a.55'],[pth 'fr_a\fr_a.56'],[pth 'fr_a\fr_a.57'],[pth 'fr_a\fr_a.58'],[pth 'fr_a\fr_a.59'],[pth 'fr_a\fr_a.103'],[pth 'fr_a\fr_a.104'],[pth 'fr_a\fr_a.105'],[pth 'fr_a\fr_a.106']);
%trace_legend = str2mat('1','2','3','4','5','6','7','8','9','10');
trace_legend = [];
trace_units = 'deg C';
y_axis      = [5 25] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Tree temperatures 
%----------------------------------------------------------
trace_name  = 'Tree temperatures';
trace_path  = str2mat([pth 'fr_a\fr_a.63'],[pth 'fr_a\fr_a.64'],[pth 'fr_a\fr_a.65'],...
[pth 'uvic_01\uv01a.19'],[pth 'uvic_01\uv01a.20'],[pth 'uvic_01\uv01a.21'],[pth 'uvic_01\uv01a.22'],[pth 'uvic_01\uv01a.23']);
trace_legend = str2mat('#1-3m 0.2 cm','#1-3m 8.2 cm','#1-3m 16.4 cm','#2-3m 0.2 cm','#2-3m 5 cm','#2-3m 15 cm','#2-27m 0.2 cm','#2-27m 2.8 cm');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Air temperatures at 35m
%----------------------------------------------------------
trace_name  = 'Air temperatures at 35m and 42m';
trace_path  = str2mat([pth 'fr_a\fr_a.17'],[pth 'fr_a\fr_a.75'],[pth 'fr_a\fr_a.21'],[pth 'fr_a\fr_a.47'],[pth 'fr_b\fr_b.23'],[pth 'fr_f\fr_f.25'],[pth 'fr_f\fr_f.26']);
trace_legend = str2mat('HMP\_27m Gill','HMP\_41m Met-1','TC','Hut\_{airT}','GillT','Prof 15\_3','Prof 44\_3');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Temperature profile
%----------------------------------------------------------
trace_name  = 'Temperature profile';
trace_path  = str2mat([pth 'fr_f\fr_f.17'],[pth 'fr_f\fr_f.18'],[pth 'fr_f\fr_f.19'],[pth 'fr_f\fr_f.20'], ...
                      [pth 'fr_f\fr_f.21'],[pth 'fr_f\fr_f.22'],[pth 'fr_f\fr_f.23'],[pth 'fr_f\fr_f.24']);
trace_legend = str2mat('T2m','T5m','T9m','T15m','T21m','T27m','T33m','T44m');
trace_units = '(degC)';
y_axis      = [ 0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sampling tube temp.
%----------------------------------------------------------
trace_name  = 'Sampling tube temp.';
trace_path  = str2mat([pth 'fr_f\fr_f.27'],[pth 'fr_f\fr_f.28'],[pth 'fr_a\fr_a.17']);
trace_legend = str2mat('inlet1','inlet2','HMP_{27m}');
trace_units = '(degC)';
y_axis      = [0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Barometric pressure
%-----------------------------------
trace_name  = 'Pressure';
trace_path  = [pth 'fr_a\fr_a.53'];
trace_units = '(kPa)';
y_axis      = [96 100];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Relative humidity
%----------------------------------------------------------
trace_name  = 'Relative humidity';
trace_path  = str2mat([pth 'fr_a\fr_a.20'],[pth 'fr_a\fr_a.78'],[pth 'fr_a\fr_a.88']);
trace_legend = str2mat('HMP\_27m Gill','HMP\_41m Met-1','HMP\_4m Met-1');
trace_units = '(RH %)';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% HMP temperatures
%----------------------------------------------------------
trace_name  = 'HMP temperatures';
trace_path  = str2mat([pth 'fr_a\fr_a.17'],[pth 'fr_a\fr_a.75'],[pth 'fr_a\fr_a.85']);
trace_legend = str2mat('HMP\_27m Gill','HMP\_41m Met-1','HMP\_4m Met-1');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


if 1==2         % DO NOT PLOT (TOO UGLY!)
%----------------------------------------------------------
% Leaf wetness sensors
%----------------------------------------------------------
trace_name  = 'Leaf wetness sensors';
trace_path  = str2mat([pth 'fr_a\fr_a.89'],[pth 'fr_a\fr_a.90'],[pth 'fr_a\fr_a.91'],[pth 'fr_a\fr_a.92'],[pth 'fr_a\fr_a.93'],[pth 'fr_a\fr_a.94'],[pth 'fr_a\fr_a.95'],[pth 'fr_a\fr_a.96'],[pth 'fr_a\fr_a.97'],[pth 'fr_a\fr_a.98']);
%trace_legend = str2mat('LW1','LW2','LW3','LW4','LW5','LW6','LW7','LW8','LW9','LW10');
trace_legend = [];
trace_units = '(???)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
%-----------------------------------
% KH2O
%-----------------------------------
trace_name  = 'KH2O';
trace_path  = [pth 'fr_b\fr_b.25'];
trace_units = '(g/m^3)';
y_axis      = [0 40];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
trace_name  = 'Rain';
trace_path  = str2mat([pth 'fr_a\fr_a.24'],[pth 'fr_a\fr_a.79']);
trace_units = '(mm)';
trace_legend = str2mat('Rain 1','Rain 2');
y_axis      = [-1 10];
fig_num = fig_num + fig_num_inc;
%[x] = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative rain 
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Cumulative rain #1';
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
[x2,tx_new] = read_sig(trace_path(2,:), indx,year, tx,0);
%[x,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
fig_num = fig_num + fig_num_inc;
if year==1998
    addRain = 856.9;
else 
    addRain = 0;
end
plt_sig1( tx_new, [cumsum(x1) cumsum(x2)+addRain], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture (TDR)
%----------------------------------------------------------
trace_name  = 'Soil Moisture (TDR)';
trace_path  = str2mat([pth 'fr_a\fr_a.81'],[pth 'fr_a\fr_a.82'],[pth 'fr_a\fr_a.83'],[pth 'fr_a\fr_a.84']);
trace_legend = str2mat('2 to 3 cm','10 to 12 cm','35 to 48 cm','70 to 100 cm');
trace_units = 'VWC';
y_axis      = [0 0.4];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
trace_name  = 'Wind speed averages (RM Young)';
trace_path  = str2mat([pth 'fr_a\fr_a.27'], [pth 'fr_c\fr_c.28']);
trace_legend = str2mat('37m (avg)','3.5m (avg)');
trace_units = '(m/s)';
y_axis      = [0 8];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (max)(RM Young)
%----------------------------------------------------------
trace_name  = 'Wind speed (max)(RM Young)';
trace_path  = str2mat([pth 'fr_a\fr_a.28'],[pth 'fr_c\fr_c.29']);
trace_legend = str2mat('37m (max)','3.5m (max)');
trace_units = '(m/s)';
y_axis      = [0 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
trace_name  = 'Wind direction (RM Young)';
trace_path  = str2mat([pth 'fr_a\fr_a.32'],[pth 'fr_c\fr_c.33']);
trace_legend = str2mat('38m','3.5m');
trace_units = '(m/s)';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Gas Hound co2 concentration 
%----------------------------------------------------------
trace_name  = '10m CO2 concentration (Gashound)';
trace_path  = str2mat([pth 'fr_c\fr_c.49'],[pth 'fr_c\fr_c.50'],[pth 'fr_c\fr_c.51']);
trace_legend = str2mat('avg','max','min');
trace_units = '(umol/m2/s)';
y_axis      = [360 440];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PAR 1,2
%-----------------------------------
trace_name  = 'PAR ';
trace_path  = str2mat([pth 'fr_a\fr_a.38'],[pth 'fr_a\fr_a.40']);
trace_legend = str2mat('downward','upward');
trace_units = '(mmol m^{-2} s^{-1})';
y_axis      = [-100 1800];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PSP
%-----------------------------------
trace_name  = 'PSP';
trace_path  = str2mat([pth 'fr_a\fr_a.42'],[pth 'fr_a\fr_a.44'],[pth 'fr_a\fr_a.101'],...
   [pth 'fr_a\fr_a.119'],[pth 'fr_a\fr_a.120']);
trace_legend = str2mat('down','up','down\_gnd','CNR1 down','CNR1 up');

trace_units = '(W/m^2)';
y_axis      = [-100 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

end

%-----------------------------------
% Net
%-----------------------------------
trace_name  = 'Net Radiation';
trace_path  = str2mat([pth 'fr_a\fr_a.51'],[pth 'fr_a\fr_a.99'],[pth 'fr_a\fr_a.125']);
trace_legend = str2mat('Net 1','Net 2','CNR1');

trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 21.758/19.686 1 ]);
if pause_flag == 1;pause;end


%-----------------------------------
% Net 1:1 CNR1:ST1
%-----------------------------------
trace_name  = 'Net Radiation CNR1:ST1';
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
figure(fig_num)
clf
x=x_all(:,1);
y = x_all(:,3);
ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
index = find(x > -200 & x <=1000);
[p1,x1,y1] = polyfit_plus(x(index(1:round(end*2/3))),y(index(1:round(end*2/3))),1);
%[p2,x2,y2] = polyfit_plus(x(index(end*2/3:end)),y(index(end*2/3:end)),1);
%plot(x1,y1,'.',x1,polyval(p1,x1),x1,x1,x1,polyval(p2,x1));
plot(x1,y1,'.',x1,polyval(p1,x1),x1,x1);
grid on;
zoom on;
xlabel('Net 1')
ylabel('CNR1')
axis([-200 1000 -200 +1000])
title(trace_name)
text(200,100,sprintf('CNR1 = %f NET1 + (%f)',p1),'fontsize',10);
%text(200,150,sprintf('CNR1 = %f NET1 + (%f)',p2),'fontsize',10);
if pause_flag == 1;pause;end

%-----------------------------------
% Net 1:1 ST2:ST1
%-----------------------------------
trace_name  = 'Net Radiation ST2:ST1';
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
figure(fig_num)
clf
x=x_all(:,1);
y = x_all(:,2)*21.758/19.686;
ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
index = find(x > -200 & x <=1000);
[p1,x1,y1] = polyfit_plus(x(index(1:round(end*2/3))),y(index(1:round(end*2/3))),1);
%[p2,x2,y2] = polyfit_plus(x(index(end*2/3:end)),y(index(end*2/3:end)),1);
%plot(x1,y1,'.',x1,polyval(p1,x1),x1,x1,x1,polyval(p2,x1));
plot(x1,y1,'.',x1,polyval(p1,x1),x1,x1);
grid on;
zoom on;
xlabel('Net 1')
ylabel('Net 2')
axis([-200 1000 -200 +1000])
title(trace_name)
text(200,100,sprintf('Net2 = %f NET1 + (%f)',p1),'fontsize',10);
%text(200,150,sprintf('CNR1 = %f NET1 + (%f)',p2),'fontsize',10);
if pause_flag == 1;pause;end


%-----------------------------------
% w^w
%-----------------------------------
trace_name  = '\sigma^2_w';
trace_path  = [pth 'fr_b\fr_b.28'];
trace_units = '(m/s)^2';
y_axis      = [0 6];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% w
%-----------------------------------
trace_name  = 'Gill R2: W';
trace_path  = [pth 'fr_b\fr_b.22'];
trace_units = '(m/s)';
y_axis      = [-1 1];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (Gill R2)
%----------------------------------------------------------
trace_name  = 'Wind speed (Gill R2)';
trace_path  = str2mat([pth 'fr_b\fr_b.20'],[pth 'fr_b\fr_b.21'],[pth 'fr_b\fr_b.22']);
trace_legend = str2mat('U','V','W');
trace_units = '(m/s)';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed comparison
%----------------------------------------------------------
trace_name  = 'Wind speed RM Young vs Gill R2';
trace_path  = str2mat([pth 'fr_b\fr_b.20']);
trace_units = '(m/s)';
y_axis      = [];
ax = [st ed];
indx = find( t_all >= st & t_all <= ed );                   % extract the requested period 
tx = t_all(indx);                                           % 
[U,tu] = read_sig(trace_path, indx,year, tx,0);
trace_path  = str2mat([pth 'fr_b\fr_b.21']);
[V,tv] = read_sig(trace_path, indx,year, tx,0);
trace_path  = str2mat([pth 'fr_a\fr_a.27']);
[CupRMYoung,tc] = read_sig(trace_path, indx,year, tx,0);
trace_path  = str2mat([pth 'fr_b\fr_b.47']);
[CupGill,tc] = read_sig(trace_path, indx,year, tx,0);
trace_path  = str2mat([pth 'fr_b\fr_b.48']);
[CupGill3D,tc] = read_sig(trace_path, indx,year, tx,0);
CupGill1 = (U.^2 + V .^2).^0.5;
Ntc = length(tc);
Ntu = length(tu);
NNN = min(Ntc,Ntu);
if tc(1) == tu(1)
    nnn = 1:NNN;
elseif  tc(Ntc) == tu(Ntu)
    error 'I am not prepared to do this'
end
fig_num = fig_num + fig_num_inc;
plt_sig1( tc, [CupRMYoung(nnn) CupGill(nnn) CupGill1(nnn) CupGill3D(nnn)], trace_name, year, trace_units, ax, y_axis, fig_num );
legend('RMYoung','Gill-hf','GillHH','Gill3D',-1)
if pause_flag == 1;pause;end

if 1==2
%----------------------------------------------------------
% Sensible and latent heat + Rn
%----------------------------------------------------------
trace_name  = 'H_{Gill}, H_{tc}, LE and Rn';
trace_path  = str2mat([pth 'fr_b\fr_b.41'],[pth 'fr_b\fr_b.42'],[pth 'fr_b\fr_b.43'],[pth 'fr_a\fr_a.51']);
trace_legend = str2mat('H\_{Gill}','H\_{tc}','LE','Rn');
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1150 1150 2540 1] );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Closure
%----------------------------------------------------------
trace_name  = 'Closure';
trace_path  = str2mat([pth 'fr_b\fr_b.41']);
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
ax = [st ed];
indx = find( t_all >= st & t_all <= ed );                   % extract the requested period 
tx = t_all(indx);                                           % 
[H,tx_new] = read_sig(trace_path, indx,year, tx,0);
H = H * 1150;
trace_path  = str2mat([pth 'fr_b\fr_b.43']);
[LE,tx_new] = read_sig(trace_path, indx,year, tx,0);
LE = LE * 2540;
trace_path  = str2mat([pth 'fr_a\fr_a.51']);
[Rn,tx_rn] = read_sig(trace_path, indx,year, tx,0);
fig_num = fig_num + fig_num_inc;
Ntc = length(tx_new);
Ntu = length(tx_rn);
NNN = min(Ntc,Ntu);
if tc(1) == tu(1)
    nnn = 1:NNN;
elseif  tc(Ntc) == tu(Ntu)
    error 'I am not prepared to do this'
end
plt_sig1( tx_new(nnn), [H(nnn)+LE(nnn) Rn(nnn) Rn(nnn)-H(nnn)-LE(nnn)], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% Sensible heat Gill vs TC
%----------------------------------------------------------
trace_name  = 'H_{Gill} vs H_{tc}';
trace_path  = str2mat([pth 'fr_b\fr_b.41'],[pth 'fr_b\fr_b.42']);
trace_legend = str2mat('H\_{Gill}','H\_{tc}');
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1150 1150] );
if pause_flag == 1;pause;end

if 1==2
%----------------------------------------------------------
% LICOR heater/fan duty cycles
%----------------------------------------------------------
trace_name  = 'LICOR heater/fan duty cycles';
trace_path  = str2mat([pth 'fr_c\fr_c.26'],[pth 'fr_c\fr_c.27']);
trace_legend = str2mat('Heater','Fan');
trace_units = '(%)';
y_axis      = [-10 120];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[100 100]);
if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% LICOR box temperature
%----------------------------------------------------------
trace_name  = 'LICOR  box temperature';
trace_path  = str2mat([pth 'fr_c\fr_c.9']);
trace_legend = str2mat('Box');
trace_units = '(degC)';
y_axis      = [10 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Generator hut temperatures
%----------------------------------------------------------
trace_name  = 'Generator hut temperatures';
trace_path  = str2mat([pth 'fr_c\fr_c.46'],[pth 'fr_a\fr_a.47']);
trace_legend = str2mat('Tc 2m','Air T');
trace_units = '(degC)';
y_axis      = [-10 50];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sap Flow Gauges
%----------------------------------------------------------
trace_name  = 'Sap Flow Gauges';
trace_path  = str2mat([pth 'uvic_01\uv01b.13'],[pth 'uvic_01\uv01b.14'],[pth 'uvic_01\uv01b.15']);
trace_legend = str2mat('#1','#2','#3');
trace_units = 'dT(degC)';
y_axis      = [4 12];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Throughfall
%----------------------------------------------------------
trace_name  = 'Throughfall troughs'; %calibration for slow tip rate
trace_path  = str2mat([pth 'dave\dave1.7'],[pth 'dave\dave1.8'],[pth 'dave\dave1.9'],[pth 'dave\dave1.10'],[pth 'dave\dave1.11']);
trace_legend = str2mat('#1','#2','#3','#4','#5');
trace_units = 'mm';
y_axis      = [0 5];
coeff       = [0.05 0.051 0.048 0.051 0.051];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, coeff );
if pause_flag == 1;pause;end




%colordef white

if pause_flag ~= 1;
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=childn(:)';
        if i < 200 
            figure(i);
            if i ~= childn(N-1)
                pause;
            end
        end
    end
end

%========================================================
% local functions

function [p,x1,x2] = polyfit_plus(x1in,x2in,n)
    x1=x1in;
    x2=x2in;
    tmp = find(abs(x2-x1) < 0.5*abs(max(x1,x2)));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);


% Older revisions
%       June 2, 1998
%           -   corrected TC height 35m to 33m 
%           -   corrected TDR depths
%       May 19, 1998
%           -   added second rain gauge to rain plot
%           -   added Ref tank days remaining calculation
%       May 12, 1998 
%           -   changed battery voltage plots
%           -   added TDR plots 
%       May  7, 1998
%           -   added support for the local data base LOCAL_PATH
%       May  4, 1998
%           -   plotting of heat flux plates has been added.
%           -   second rain gauge is in
%       Apr  7, 1998
%           -   added an estimation of the generator run-time. It's printed
%               on the same graph as BB#1 & BB#2.
%       Apr  4, 1998
%           -   change of axis (summer setup)
%           -   chaged EdyPth to \\class\paoa\paoa (instead \\boreas_003 or h:\zoran\paoa
%       Mar 25, 1998
%           -   ploting with 'colordef none' by default. Changes to 'colordef white'
%               before exiting.
%		  Mar  4, 1998
%				- added two more graphs (BB #1 & #2 voltages and currents)
%				- added fr_d battery voltage to Battery Voltage plot
%
%		  Feb 27, 1998
%				- increase y-axis range from 2200 to 2600 psi
%
%		  Feb 17, 1998
%				-	added temp and voltage plots for fr_e (gen hut 21x)
%	
%		  Feb  5, 1998
%				-	Added support for 1998 (program now defaults to 1998 instaed 1997)
%	
%		  Feb 2, 1998
%				- plot tank pressures
%				- changed GMTshift from 7/24 to 8/24
%				- tree temps
%				- snow temps
%				- second HMP on humidity and air temp
%
% 		  Dec 21, 1997
%				-	More axis changes
%       Nov 20, 1997
%           - legend changes
%       Oct  5, 1997
%           Added barometric pressure
%       Sep  22, 1997
%           Added FR_C Fan/Heater duty cycles, box/sample cell temperature. Fixed
%           cummulative rain plot.
%       Sep  1, 1997
%           Changed axes for wind speed and closure.
%       Aug 29, 1997
%           Added H_tc to the energy plots.
%       Aug 10, 1997
%           Added proper Gill cup wind speed and wind speed vector (Gill3D) plotting.
%       Aug 10, 1997
%           Solved problem with unequal lengths of CupRMYoung and CupGill files
%       Aug  5, 1997
%           Added net radiometer and Panel Temp #3 plotting
%       Jul 15, 1997
%           Added phone battery voltage and hut air temperature
%           to the plots.
%       Jul  8, 1997
%           Created program using paoa_pl.m as a starting point
