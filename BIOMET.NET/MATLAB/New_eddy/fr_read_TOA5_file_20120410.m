function [EngUnits,Header,tv] = fr_read_TOA5_file(fileName,time_str_flag,headerlines,defaultNaN,assign_in,strbuffsize)
% [EngUnits,Header,tv] = fr_read_TOA5_file(fileName,time_string_flag,headerlines,defaultNaN,asign_flag)
%
% Read CSI TOA5 files (ascii output tables from table based loggers)
% 
% Inputs:
%   fileName            - file in TOA5 format
%   time_str_flag       - 1: if the first column is a time string
%                       - 0: otherwise
%   headerlines         - number of lines in the header (usually 4)
%   defaultNaN          - a string to use to indicate bad data (usually
%                         it's '-999' or 'NaN' (default) 
%   assign_in           - 'caller', 'base' - assignes the data to the
%                           actual column header names (logger variables)
%                           either in callers space or in the base space.
%                           If empty or 0 no
%                           assignments are made
%   strbuffsize         - Max string length that textread will work with.
%
% This function originaly appeared as fcrn_read_csi_ascii.m (Kai/Zoran).
% It was then revised by Zoran to incorporate the best parts of other
% derivations of the same function.  It replaces:
%   - fcrn_read_csi_ascii.m
%   - fr_read_CRBasic_file.m
% and all their subvariants.
%
% (c) Zoran Nesic (Kai Morgenstern in absence) File created:      Jun  8,2010
%                                              Last modification: Oct 21,2011
%

% Revisions:
%
% Oct 21, 2011 (Zoran)
%   - changed the way program reads logger SN. (bug)
%      from: Header.loggerSN = str2double(char(Header.line1(2))); (this is logger name!)
%      to:   Header.loggerSN = str2double(char(Header.line1(4)));
%   - added an additional input parameter strbuffsize (max string length that can be read) so
%     that this program matches fcrn_read_csi_ascii
%   - added "-INF" in the list of parameters that will be replaced by defaultNaN


arg_default('time_str_flag',1)
arg_default('headerlines',4)
arg_default('defaultNaN','NaN')
arg_default('assign_in',0)
arg_default('strbuffsize',10000)

% Find no of variables in file
s_read = textread(fileName,'%q',1,'headerlines',headerlines,'bufsize',strbuffsize);
N = length(split_line(char(s_read)));

% Read header
if headerlines > 0
    for i = 1:headerlines
        s_read = textread(fileName,'%q',1,'headerlines',i-1,'bufsize',strbuffsize);
        eval(['Header.line' num2str(i) ' = split_line(char(s_read));']);
    end
    var_names = Header.line2;
    var_names = regexprep(var_names,'\(','');
    var_names = regexprep(var_names,'\)','');
    var_names = regexprep(var_names,'[','');
    var_names = regexprep(var_names,']','');
else
    for i = 1:N
        var_names(i) = {['x_' num2str(i)]};
    end
end

% Extract some parameters from the header
Header.loggerSN = str2double(char(Header.line1(4)));
Header.loggerType = char(Header.line1(3));
Header.loggerOS = char(Header.line1(5));
Header.programName = char(Header.line1(6));
Header.programName = Header.programName(5:end);

% Create format string
if time_str_flag==1
    formatStr = '%q';
    formatStr2 = char(ones(N-1,1)*' %f')';
    var_names_numbers = {'TIMESTAMP'};
else
    formatStr = '';
    formatStr2 = char(ones(N,1)*' %f')';
end

if headerlines == 4 % 4th line contain variable type
    for i = 2:N
        % Only export any variables that are numbers
        switch char(Header.line4(i))
            case {'TMx','TMn'}
                formatStr = [formatStr ' %*s'];
            otherwise
                formatStr = [formatStr ' %f'];
                var_names_numbers = [var_names_numbers var_names(i)];
        end
    end
    var_names = var_names_numbers;
    N = length(var_names);
else
    formatStr = [formatStr formatStr2(:)'];
    formatStr = formatStr(:)';
    formatStr = [formatStr];
end
Header.var_names = var_names(2:end);

outStr = ['['];
for i = 1:N
    outStr = [outStr char(var_names(i)) ' '];
end
outStr = [outStr ']'];    

try
    eval([outStr ' = textread(fileName,formatStr,-1,''delimiter'','','',''headerlines'',headerlines);']);    
catch
    % load everything as a big char array
    fid=fopen(fileName,'r');
    q_read = char(fread(fid,inf,'uchar'))';
    fclose(fid);

    q_read = replace_string(q_read,'-1.#IND',defaultNaN);
    q_read = replace_string(q_read,'"NAN"',defaultNaN);
    q_read = replace_string(q_read,'-1.#QNAN',defaultNaN);   
    q_read = replace_string(q_read,'"INF"',defaultNaN);   
    q_read = replace_string(q_read,'"-INF"',defaultNaN);    
    % the following is much slower!!
    %    q_read = regexprep(q_read,'"NAN"',defaultNaN);

    tempFileName = 'c:\temp.junk';
    fid = fopen(tempFileName,'w');
    fwrite(fid,q_read,'uchar');
    fclose(fid);
    eval([outStr ' = textread(tempFileName,formatStr,-1,''delimiter'','','',''headerlines'',headerlines);']);    
end

outStr = '[';
for i = 2:N
    outStr = [outStr  char(var_names(i)) ' '];
    if assign_in ~= 0
        eval(['assignin(assign_in,char(var_names(i)),' char(var_names(i)) ');']);
    end
end
outStr = [outStr ']'];    

eval(['EngUnits = ' outStr ';']);   
    
% Export time vector if exists and is requested as an output
if time_str_flag && nargout > 2
%   "2005-05-26 01:30:00"
    tv_char = char(TIMESTAMP);
    tv = datenum(str2num(tv_char(:,1:4)),str2num(tv_char(:,6:7)),str2num(tv_char(:,9:10)),...
        str2num(tv_char(:,12:13)),str2num(tv_char(:,15:16)),str2num(tv_char(:,18:19)));
    % Deal with missing years in time stamp that happen in strread above
    if isempty(tv)
        for i = 1:length(tv_char)
            tv_tmp = datenum(str2num(tv_char(i,1:4)),str2num(tv_char(i,6:7)),str2num(tv_char(i,9:10)),...
                str2num(tv_char(i,12:13)),str2num(tv_char(i,15:16)),str2num(tv_char(i,18:19)));
            if ~isempty(tv_tmp)
                tv(i) = tv_tmp;
            else
                tv(i) = NaN;
            end
        end
        ind_nan = find(isnan(tv));
        ind_nonan = find(~isnan(tv));
        tv(ind_nan) = interp1(ind_nonan,tv(ind_nonan),ind_nan);
        tv = tv';
    end
else
    tv = NaN;
end

if assign_in ~= 0
    assignin(assign_in,'tv_csi',tv);
end

end

function line_cell = split_line(line_str)

line_str = regexprep(line_str,'"','');
ind = [0 strfind(line_str,',')];

for i = 1:length(ind)-1
    line_cell(i) = {line_str(ind(i)+1:ind(i+1)-1)};
end
line_cell(i+1) = {line_str(ind(end)+1:end)};
end

%-------------------------------------------------------------------
% function replace_string
% replaces string findX with the string replaceX and padds
% the replaceX string with spaces in the front to match the
% length of findX.
% Note: this will not work if the replacement string is shorter than
%       the findX.
function strOut = replace_string(strIn,findX,replaceX)
    % find all occurances of findX string
    ind=findstr(strIn,findX);
    strOut = strIn;
    N = length(findX);
    M = length(replaceX);
    if ~isempty(ind)
        %create a matrix of indexes ind21 that point to where the replacement values
        % should go
        x=[0:N-1];
        ind1=x(ones(length(ind),1),:);
        ind2=ind(ones(N,1),:)';
        ind21=ind1+ind2;

        % create a replacement string of the same length as the strIN 
        % (Manual procedure - count the characters!)
        strReplace = [char(ones(1,N-M)*' ') replaceX];
        strOut(ind21)=strReplace(ones(length(ind),1),:);
    end    
    
end
