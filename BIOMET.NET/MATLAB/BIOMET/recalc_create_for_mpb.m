function recalc_create_for_mpb(SiteId,Years,base_path)

%==========================================================================
% Create base directory 
% If it already exists stop because it might already be in use. If user
% wants to use this name it'll have to be deleted manually.
% [s,mes] = mkdir(base_path,dir_name);
% if ~isempty(mes)
%     disp(mes);
%     disp('... returning');
%     diary off    
%     return
% end

base_dir = base_path;

%==========================================================================
% Start log file
diary(fullfile(base_dir,'recalc.log'));
disp(sprintf('== Creating recalculation setup =='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('SiteId = %s',SiteId));

%==========================================================================
% Get the Site name
All_Sites     = {'MPB1' 'MPB2' 'MPB3' 'MPB3' 'HP09' 'HP11' 'SQT'};
All_Site_name = {'MPB1' 'MPB2' 'MPB3' 'MPB3' 'HP09' 'HP11' 'SQT'};
[dum,ind_id] = intersect(upper(All_Sites),upper(SiteId));
if isempty(ind_id)
    disp(sprintf('The requested site ID: %s has not been found among the known site names: ',SiteId))
    disp(All_Sites)
    disp('... returning');
    diary off
    return
end
SiteName = char(All_Site_name(ind_id));

%==========================================================================
% Copy and create biomet setup matlab files
% disp('Copying biomet.net...');
% [s,mes] = mkdir(base_dir,'Biomet.net\Matlab');
% [s,mes] = copyfile('\\paoa001\matlab',[base_dir '\Biomet.net\Matlab']);
% if ~isempty(mes)
%     disp(mes)
%     disp('... returning');
%     diary off
%     return
% else
%     disp(sprintf('%s - done',datestr(now)));
% end

%==========================================================================
% Copy Site_Specific

disp('Copying Site_specific...');
[s,mes] = mkdir(base_dir,'UBC_PC_SETUP\Site_specific');
[s,mes] = copyfile(['\\paoa001\Sites\' SiteName '\UBC_PC_SETUP\Site_specific\*.m'],[base_dir '\UBC_PC_SETUP\Site_specific']);
% PC_specific is not copied since we use the one on the current PC
if ~isempty(mes)
    disp(mes)
    disp('... returning');
    diary off
    return
else
    disp(sprintf('%s - done',datestr(now)));
end

disp('Creating fr_get_local_path.m...');
% if on the network overwrite fr_get_local_path
fid = fopen([base_dir '\UBC_PC_SETUP\Site_specific\fr_get_local_path.m'],'wt');
if fid > 0
    fprintf(fid,'%s\n','function [dataPth,hhourPth,databasePth,csiPth] = FR_get_local_path');
    fprintf(fid,'%% This function was generated by recalc_create.m\n');
    fprintf(fid,'dataPth  = %s%s%s;\n',char(39),fullfile(base_dir,'\met-data\data\'),char(39));
    fprintf(fid,'hhourPth  = %s%s%s;\n',char(39),fullfile(base_dir,'\met-data\hhour\') ,char(39));
    fprintf(fid,'databasePth  = %s%s%s;\n',char(39),'\\ANNEX001\Database\',char(39));
    fprintf(fid,'csiPth  = %s%s%s;\n',char(39),['\\FLUXNET02\HFREQ_' upper(SiteId) '\met-data\csi_net\'],char(39));
    fclose(fid);
else
    disp(['Could not create ' base_dir '\UBC_PC_SETUP\Site_specific\fr_get_local_path.m'])
    disp('... returning');
    diary off
    return
end
disp(sprintf('%s - done',datestr(now)));

disp('Copying calibration files...');

%3/10/2010: Nick added the '*' wildcard before calibrations to catch manual
%cal files
[s,mes] = copyfile(['\\paoa001\Sites\' SiteName '\hhour\*calibrations*.*'],[base_dir '\met-data\hhour']); 
if ~isempty(mes)
    disp(['**************** -> Error: ' mes])
    %disp('... returning');
    %return
else
    disp(sprintf('%s - done',datestr(now)));
end

diary(fullfile(base_dir,'recalc.log'));
disp(sprintf('== Finished recalculation setup =='));
diary off
return

