function k = DB_main_update_profile(pthIn,wildcard,pthOut)
% eg. k = db_main_update_profile('\\annex001\database\2000\pa\profile\raw\',
%                                '0001*.prof.mat','\\annex001\database\2000\pa\profile\');
% would update the database using all Jan 2000 files
%
% k = tmp_db_main_update_profile('\\PAOA001\Sites\PAOA\HHour\','0109*s.hp.mat','D:\david_data\data\profile\2001\PA\raw\')
% k = tmp_db_main_update_profile('\\PHD002\D\david_data\hhour\PA\','01*.hp.mat','D:\david_data\data\profile\2001\PA\raw\')
%  
%   This function updates profile database files.
%
%   It reads data from hhour files stored in the pthIn directory and updates database located in pthOut
%   
%   Inputs:
%           pthIn       -   raw data path (*.mat files)
%           wildcard    -   narrow down the choice of mat files to be processed
%           pthOut      -   data base location for the output data
%   Outputs:
%           k           -   number of files processed
%
%
% (c)                   File created:       Jun  8, 2001
%                       Last modification:  Jun  8, 2001
%
% Revisions:

pth_tmp = fr_valid_path_name(pthIn);          % check the path and create
if isempty(pth_tmp)                         
    error 'Directory does not exist!'
else
    pthIn = pth_tmp;
end

pth_tmp = fr_valid_path_name(pthOut);          % check the path and create
if isempty(pth_tmp)                         
    error 'Directory does not exist!'
else
    pthOut = pth_tmp;
end

D = dir([pthIn wildcard]);
n = length(D);
k = 0;
tic;
for i=1:n
    %if D(i).isdir == 0 & ~strcmp(D(i).name(7),'s')       % avoid directories and short form hhour files
    if D(i).isdir == 0        % avoid directories, use short form hhour files (Jan 18, 2000)
        if find(D(i).name == ':' | D(i).name == '\') 
            x = load(D(i).name);
        else
            x = load([pthIn D(i).name]);
        end
        disp(sprintf('Processing: %s',D(i).name))
        OutputData = DB_update_profile(x.stats,pthOut);
        k = k+1;
    end
end
tm = toc;
disp(sprintf('%d files processed in %d seconds.',round([k tm])))
