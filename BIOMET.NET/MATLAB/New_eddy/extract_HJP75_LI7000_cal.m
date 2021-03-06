function  [cal_values_new,HF_data,cal_values] = extract_HJP75_LI7000_cal(dateIn)

if ~exist('dateIn') | isempty(dateIn)
    dateIn = fix(now)+datenum(0,0,0,7,1,0);
end

ind_HF_data = [1250 1350];
ind_CAL0 = [1600 1700];
ind_CAL1 = [2100 2200];
ind_Ambient_before = [500 600];
ind_Ambient_after = [10000 10100];
ind_all = [ind_HF_data ; ind_CAL0 ; ind_CAL1 ;ind_Ambient_before ; ind_Ambient_after] ;
instrumentNum = 2;
saveHF_flag = 1;
overwriteCal_flag = 0;
CAL1_ppm = 362;

%for i=1:30;
    try;
        [cal_values_new,HF_data,cal_values] = extract_LI7000_calibrations(dateIn,instrumentNum, ...
                                        ind_all, CAL1_ppm,saveHF_flag,overwriteCal_flag);
    end;
%end
if nargout == 0
    clear cal_values_new HF_data cal_values
end