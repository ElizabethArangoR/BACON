function [output] = read_OPEC_EdiRe(load_path)

ls = addpath_loadstart;
% Navigate to the right directory if not specified by load_dir
if nargin == 0 ||isempty(load_path)==1
        [filename pathname] = uigetfile([ls 'EdiRe/*.*'],'Please navigate to directory with conditioned data in it');
load_path = [pathname filename];
end
disp(['Loading file: ' load_path]);
% OPEN THE FILE:
fid = fopen(load_path);

% Get the first line with the headers:
tline = fgets(fid);

%%% Separate headers and put them into a cell matrix:
coms = find(tline == ',');
coms = [0 coms length(tline)+1];

for i = 1:1:length(coms)-1
    tmp_varname = tline(coms(i)+1:coms(i+1)-1);
    tmp_varname(tmp_varname == '"') = ''; %remove quotation marks.
    tmp_varname(isspace(tmp_varname)==1) = '';
%     tmp_varname(tmp_varname(1,1:2) == ' ') = ''; % removes spaces
    varnames{i+5,1} = tmp_varname;
    clear tmp_varname;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MAKE A FORMAT STRING for extracting the remaining data:
format_string = '%s';
for k = 2:1:length(coms)-1
    format_string = [format_string ' %n'];
end
%%%%%%%%%%%%%%%%%%%%%%%

%%% Load the rest of the data in:
eofstat = 0;
row_ctr = 1;

clear tmp_data timestamp;
% timestamp = [];
while eofstat == 0;
    %%% Read all data fields using textscan:
%     try
        % The CommentStyle command is critical for ignoring "NaN" values in
        % the data file, which MATLAB thinks is a string because of the quotation marks.
        %         tmp_data = textscan(fid,format_string,200,'Delimiter',',','EmptyValue', NaN,'CommentStyle', {'"N', 'N"'});
        tmp_data = textscan(fid,format_string,50,'Delimiter',',','EmptyValue', NaN);
        %%% Timestamp from data:
        rows_to_add = length(tmp_data{1,1});
        try
            if row_ctr > 1
            clear rr cc;
            [rr cc] = size(char(tmp_data{1,1}));
            
            [rr2 cc2] = size(timestamp);
            diff = cc2-cc;
            if diff > 0 % means we need to pad tmp_data
                for jj = 1:1:rr
                tmp_data{1,1}{jj,1} = [tmp_data{1,1}{jj,1} ' '];
                end
            elseif diff < 0 % means we need to pad timestamp
                for jj = 1:1:rr2
                    timestamp(jj,:) = [timestamp(jj,:) ' '];
                end
            end
            end  
                
        timestamp(row_ctr:row_ctr+rows_to_add-1,:) = char(tmp_data{1,1});
        catch
            disp();
        end
        for k = 2:1:length(tmp_data)
            % fixes the case where one column may be shorter than the rest
            % (I don't know why this would happen, but it does).
            if length(tmp_data{1,k}) < rows_to_add
                tmp_switch = tmp_data{1,k};
                tmp_switch = [tmp_switch ; NaN.*ones(rows_to_add - length(tmp_data{1,k}))];
                tmp_data{1,k} = tmp_switch;
                clear tmp_switch
            end

            data(row_ctr:row_ctr+rows_to_add-1,k) = tmp_data{1,k}; % start at column 2 and then add timevec back in later
        end
        row_ctr = row_ctr + rows_to_add;
        clear tmp_data rows_to_add;
        eofstat = feof(fid);
%     catch
%         disp(row_ctr);
%         s = input('error');
%     end
end
fclose(fid);

%%% Add 12 hours to any time that is reported as 'AM' -- This makes the
%%% time metric, which is much easier to handle:
[r c] = size(timestamp);
add_to_hours = zeros(r,1);
hh = NaN.*ones(r,1);
mm = NaN.*ones(r,1);

%%%% Make it so we can accept 2 different time formats: %%%%%%%%%
first_space = find(timestamp(1,:) == ' ',1,'first');
clear yyyy MON DAY

yyyy(1:r,1) = NaN;
MON(1:r,1) = NaN;
DAY(1:r,1) = NaN;

if first_space == 9;
    yyyy = 2000 + str2num(timestamp(:,7:8));
    MON = str2num(timestamp(:,4:5));
    DAY = str2num(timestamp(:,1:2));
    if isempty(yyyy) || isempty(MON) || isempty(DAY)
        for i = 1:1:r
            try
                yyyy(i,1) = 2000 + str2num(timestamp(i,7:8));
                MON(i,1) = str2num(timestamp(i,4:5));
                DAY(i,1) = str2num(timestamp(i,1:2));
            catch
                disp(['Check line ' num2str(i+1) ' in the input file for an error.']);
            end
            
        end
    end
    
else
    yyyy =str2num(timestamp(:,1:4));
    MON = str2num(timestamp(:,6:7));
    DAY = str2num(timestamp(:,9:10));
    if isempty(yyyy) || isempty(MON) || isempty(DAY)
        
        for i = 1:1:r
            try
                yyyy(i,1) =str2num(timestamp(i,1:4));
                MON(i,1) = str2num(timestamp(i,6:7));
                DAY(i,1) = str2num(timestamp(i,9:10));
            catch
                disp(['Check line ' num2str(i+1) ' in the input file for an error.']);
            end
        end
    end
end

for i = 1:1:r
    % extract hour, minute, and second from the data:
    colons = find(timestamp(i,:) == ':');
    hh(i,1) = str2num(timestamp(i,colons(1)-2:colons(1)-1));
    mm(i,1) = str2num(timestamp(i,colons(1)+1:colons(1)+2));
    
    ispm = find(timestamp(i,:) =='P');
    if ~isempty(ispm) && hh(i,1) < 12; % shifts PM to 24-hour clock
       add_to_hours(i,1) = 12;
       
    elseif isempty(ispm) && hh(i,1) == 12; % shifts 12AM to 0 hours
        add_to_hours(i,1) = -12;
    end
   
   
   clear m_ind
end
%%% EdiRe outputs the data with the timestamp that is the middle of the 
%%% half-hour.  So, we have to add 15 minutes to the minute column, and
%%% then add an hour (and put minute to zero) when adding 15 minutes to
%%% entries in minute column that equal 45.
hh = hh + add_to_hours;
mm = mm + 15; 
hh(mm== 60,1) = hh(mm==60,1)+1;
mm(mm==60,1) = 0;

% Make a timevector from the time information:
tv = JJB_DL2Datenum(yyyy, MON,DAY, hh, mm, 00);
% Add time data to the output data file:
data = [tv yyyy MON DAY hh mm data(1:size(data,1),2:size(data,2))];
% Add titles for the time information to the output label file:
varnames(1:6,1) = {'TimeVec';'Year';'Month';'Day';'Hour';'Minute'};

% Finally, condense both the data and the variable names into a single
% variable:
output.data = data;
output.labels = varnames;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
% 
% % %%% Convert time_stamp into a timevector
% % (JJB_DL2Datenum(YYYY,MM,DD,hh,mm,ss))
%     input_date(:,1) = JJB_DL2Datenum(yyyy, MON,DAY, hh+add_to_hours, mm, 00);
%     incr_15min = JJB_DL2Datenum(0,0,0,0,15,0);
%     input_date = input_date(:,1) + incr_15min;
%      
%     % %%% Round input_date and TV to 5 decimal places - to avoid timevector mismatch
%     input_date = (round(input_date.*100000))./100000;
% %     TV = (round(TV.*100000))./100000;
% %     % testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     input_date = input_date - 730000;
% %     master_TV = master_TV - 730000;
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figure(1);clf;
% plot(input_date);
% 
%     % %%% Find intersection points between dates in input_data and TV:
%     [row_common row_in row_master] = intersect(input_date(:,1), master_TV);
% 
%     figure(1);hold on;
%     plot(row_in,input_date(row_in),'rx');
%     
%     
%     
%     for vars = 1:1:length(varnames) % cycles through all columns in raw data file
% 
%         name_row = find(strcmp(thresh(:,2),varnames{vars})==1); % finds row in namefile where variable name exists
% %         if isempty(name_row)==1;
% %             filedata(fn).varnames(vars,1) = ['"' filedata(fn).varnames(vars,1) '"'];
% %             name_row = find(strcmp(hdr_names(:,1),filedata(fn).varnames{vars})==1); % finds row in namefile where variable name exists
% %         end
%         right_name = char(thresh(name_row,2)); % converts variable name to its final storage name
% 
%         if isempty(right_name)
%         else
% 
%             try
%                 right_name(right_name =='"') = '';
%                 right_col = find(strcmp(thresh(:,2),right_name)==1);
%                 EdiRe_all(row_master,right_col) = data(row_in,vars);
%                 clear right_col
%             catch
%                 disp(['variable ' char(right_name) ' not processed.']);
%             end
%         end
%         clear name_row right_name timestamp input_date;
% 
% 
%     end
% 
% end
% 
% save([output_path site '_EdiRe_all.mat'],'EdiRe_all');
% disp('done!');
% 
% %%%% Test it against 10-min averaged NEE data:
% load(['/home/brodeujj/Matlab/Data/Flux/OPEC/' site '_OPEC_flux.mat']);
% 
% figure(3);clf;
% 
% plot(EdiRe_all(:,47));
% axis([1 length(EdiRe_all) -40 25]);
% 
% % Load the averaged 10-min data:
% 
% 
% figure(3); hold on;
% plot(OPEC_flux.NEEraw_rot(:,1),'r');
% 
% 
% 
% 
% 
% % 
% % %%%% JUNK:
% %         data(abs(data(:,17))<20,17) = NaN;
% %         data(abs(data(:,29))<20,29) = NaN;
% %         data(abs(data(:,40))<20,40) = NaN;
% %         data(abs(data(:,44))<20,44) = NaN;
% % 
% % 
% % figure(1);clf;
% % plot(data(:,17),'b-'); hold on;
% % plot(data(:,29),'r-');
% % plot(data(:,40),'g-');
% % plot(data(:,44),'c-');
% % axis([0 1200 -15 15])
