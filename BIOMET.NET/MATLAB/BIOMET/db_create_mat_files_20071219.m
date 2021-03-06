function y = db_create_mat_files(Xwhen,SiteID,HFPth,initFile);
% This function creates mat files from HF data.  The mat files are 
% first generated locally in D:\met-data\hhour\.  If the database on
% ANNEX001 needs to be updated the files must be copied over manually.
% DO NOT run this on ANNEX001 lest something gets messed up!
%
% Note: If you are using the HF data on ANNEX001 make sure you have 
% entered the password for the appropriate HF directory before using
% this program!
%
%
% Arguments:
% Xwhen    - the date range when a mat file should be created. Never
%            more than 1 calendar yr --use datenum(yyyy,mm,dd).
% SiteID   - 2-letter (short name) site abbr.  For the harvested JP sites
%            _only_ use the full name, e.g., HJP02.
% HFPth    - location of the HF data.
% initFile - init_all file --default is '\\ANNEX001\HFREQ_xx\UBC_PC_SETUP\Site_specific\xx_init_all.m'.
%
% Example:
% db_create_mat_files(datenum(2004,1,1):datenum(2004,7,31),'JP','\\ANNEX001\HFREQ_JP\MET-DATA\data\');
% 
% This looks in ANNEX001 for the HF data and JP_init_all.m and then creates mat files from Jan-01-2004
% to Jul-31-2004 for JP.
%
% (c) Christopher R Schwalm Nov-04-2004

% Right version?
ver_check = str2num(version('-release'));
if ver_check(1) < 13
    error('Program requires MatLab release 13 or higher to run!');
end

% Enough arguments?
if nargin < 3 | nargin > 4
    error('Invalid arguments!  Try "help db_create_mat_files".')
end
SiteID = upper(SiteID);

% Create D:\met-data\hhour\ if not available
if exist('D:\met-data\hhour\') ~= 7
    mkdir('D:\','met-data\hhour\');
end

% Copy calibration files to D:\met-data\hhour\ and match PAxx sites with
% \\PAOA001\Sites\ and HJP75 exception
switch SiteID
    case 'PA'
        calibFiles = '\\PAOA001\Sites\PAOA\hhour\*.c*';
    case 'JP'
        calibFiles = '\\PAOA001\Sites\PAOJ\hhour\*.c*';
    case 'BS'
        calibFiles = '\\PAOA001\Sites\PAOB\hhour\*.c*';
    case 'HJP75'
        calibFiles = '\\ANNEX001\HFREQ_HJP75\PROJECTS\HJP75\Licor_Calibrations\LI7000\254\*.c*';
    otherwise
        calibFiles = fullfile('\\PAOA001\Sites\',SiteID,'\hhour\*.c*');
end
delete('D:\met-data\hhour\*.c*');
status = copyfile(calibFiles,'D:\met-data\hhour\');
if status == 0
    disp(' ');
    disp('No calibration files were found!');
    disp(' ');
end

% Make sure the C:\UBC_PC_Setup\Site_specific\ is present
if exist('C:\UBC_PC_Setup\Site_specific\') ~= 7
    mkdir('C:\','UBC_PC_Setup\Site_specific\');
end

% Remove old fr_get_local_path
if exist('C:\UBC_PC_Setup\Site_specific\fr_get_local_path.m') == 2
    fileattrib('C:\UBC_PC_Setup\Site_specific\fr_get_local_path.m','+w');
    delete('C:\UBC_PC_Setup\Site_specific\fr_get_local_path.m');
end

% Generate new fr_get_local_path with adjusted directories
fid = fopen('C:\UBC_PC_Setup\Site_specific\fr_get_local_path.m','w+');
fwrite(fid,'function [dataPth,hhourPth,databasePth] = FR_get_local_path');fprintf(fid,'\n');
s1 = 'dataPth = '''; s2 = HFPth; s3 = ''';'; S = strcat(s1,s2,s3);
fwrite(fid,S);fprintf(fid,'\n');
fwrite(fid,'hhourPth  = ''D:\met-data\hhour\'';');fprintf(fid,'\n');
fwrite(fid,'databasePth = ''\\annex001\Database\'';');fprintf(fid,'\n');
fwrite(fid,'% This file was generated using db_create_mat_files.');
fclose(fid);
% Note: do not remove double single quotation marks!

% Pull XX_init_all.m file from HF directory or use specific initFile
if exist('initFile') == 0 | isempty(initFile) == 1
    switch SiteID
        case 'CR'
            Tag = 'FR';
    otherwise
        Tag = SiteID;
    end
    initFile = ['\\ANNEX001\HFREQ_' SiteID '\UBC_PC_SETUP\Site_specific\' Tag '_init_all.m'];
    if exist(initFile) == 2
        fileattrib(initFile,'+w');
    end
    status = copyfile(initFile,'C:\UBC_PC_Setup\Site_specific\');  
    if status == 0
        error('Could not locate init file!');
    end
    initFile = dir(['\\ANNEX001\HFREQ_' SiteID '\UBC_PC_SETUP\Site_specific\' Tag '_init_all.m']);
    disp(' ');
    disp('========================================================================================');
    disp(['Using ' initFile.name ' from \\ANNEX001\HFREQ_' SiteID '\UBC_PC_SETUP\Site_specific']);
    disp([initFile.name ' was created on ' initFile.date]);
    disp('Override this default by using the fourth argument if desired.');
    disp('========================================================================================');
    disp(' ');   
else
    status = copyfile(initFile,'C:\UBC_PC_Setup\Site_specific\');
    if status == 0
        error('Could not locate init file!');
    end
    initFile = dir([initFile]);
    disp(' ');
    disp('========================================================================================');
    disp(['Using ' initFile.name ' created on ' initFile.date]);
    disp('========================================================================================');
    disp(' ');
end

 
% Generate mat files in D:\met-data\hhour\
switch SiteID
    case{'PA', 'BS', 'CR', 'JP'}
       [Y,M,D] = datevec(Xwhen); 
       DOY = Xwhen - datenum(Y,1,0);
       fr_calc_and_save(SiteID,Y(1),1,DOY,0);
    otherwise
       new_calc_and_save(Xwhen,SiteID,0);
end