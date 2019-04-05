function [log_filename] = mcm_auto_extractor(site,data_type)
sitename = site;
if strcmp(data_type,'chamber')==1
    site = [site '_chamber'];
end
ls = addpath_loadstart;
% log_path = [ls 'SiteData/logs/auto_extractor_logs/'];
log_path = [ls 'Documentation/Logs/mcm_auto_extractor/']; % Changed 01-May-2012

switch data_type
    case {'CPEC','chamber'}
        data_path = [ls 'DUMP_Data/' site '/'];
        jjb_check_dirs(data_path,1);
        d = dir(data_path);
        log_filename = [log_path sitename '_' data_type 'autoprocess_log_' datestr(now,10) datestr(now,5) datestr(now,7) '.txt'];
        
        diary(log_filename);
        for i = 3:1:length(d)
            %         err_flag = 0;
            % Do a first check of folder name to see if it's named properly
            if isempty(strfind(d(i).name,[sitename '_' data_type]))==1
                err_flag = 1;
            else
                err_flag = 0;
            end
            
            if err_flag ==0
                try
                    disp(['Trying to process: ' d(i).name '.']);
                    
                    mcm_extract_cpec(site, [data_path d(i).name],1);
                catch
                    err_flag = 2;
                end
            end
            
            if err_flag == 1
                disp(['Error processing folder: ' d(i).name '. Folder was named improperly.']);
                disp('Correct folder name and run again.');
            elseif err_flag == 2
                disp(['Error processing folder: ' d(i).name '. Problem while trying to extract data.']);
                disp('Check data structure and run again manually.');
            else
                disp(['Folder: ' d(i).name ' processed properly.']);
            end
            
        end
        
    case 'met'
        
end
diary off

%%% Email The log files