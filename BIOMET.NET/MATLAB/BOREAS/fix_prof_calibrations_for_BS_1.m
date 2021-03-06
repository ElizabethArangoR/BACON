% OBS profile calibration fix

% Fix to deal with the problems arising from a power issue to the
% Profile TCH box DOY 176-193, plus additional bad calibrations--one missed
% in earlier fixes (DOY 131) and one following the installation of a new 
% site PC on DOY 228.

% NickG, September 8, 2005
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal values May 11, May 20, May 30 and daily
% since June 6, 2005
ind = find(decDOY >= datenum(2005,1,1) & (cal_voltage(10,:) > 500 | cal_voltage(10,:) < -500));
% set ignore flag
cal_voltage(6,ind)= 1;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

