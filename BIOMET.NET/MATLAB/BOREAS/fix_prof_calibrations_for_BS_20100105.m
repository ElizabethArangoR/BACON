% OBS profile calibration fix 

% NickG, Jan 20, 2010
%------------------------------------------------------
% Fix bad profile licor calibrations for 2009
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20100105\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% correct for period when cal1 was shut off
% 
ind = find((decDOY>datenum(2009,1,184) & decDOY<datenum(2009,1,339)) & cal_voltage(13,:) > 0);

cal_voltage(6,ind) = 1;

% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

