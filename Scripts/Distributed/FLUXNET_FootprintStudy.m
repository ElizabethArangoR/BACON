
site_short = {'TP39', 2002:2014;'TP74', 2002:2014;'TP02', 2002:2014;'TPD', 2012:2014;'TP89', 2002:2008};

for i = 2:1:length(site_short);
mcm_data_compiler(site_short{i,2}, site_short{i,1}, 'all',-2)
end

%% TP39
to_load = { ...
'Year',1; ...
'Month',2; ...
'Day',3; ...
'Hour',4; ...
'Minute',5; ...
'dtime',6; ...
'WS [m s-1]',107; ...
'USTAR [m s-1]',11; ...
'WD [degree]',55; ...
'SIGMA_W [m s-1]',154; ...
'SIGMA_V [m s-1]',155; ...
'TA [degree C]',104; ...
'RH [%]',105; ...
'INST_HEIGHT [m]',NaN; ...
'D [m]',NaN; ...
'HEIGHTC [m]',NaN; ...
'NEE [umol CO2 m-2 s-1]',7; ...
'LE [W m-2]',9; ...
'H [W m-2]',10; ...
};

load('/1/fielddata/Matlab/Data/Master_Files/TP39/TP39_data_master.mat')
master.labels = cell(master.labels);
% Index wanted years:
ind = find(master.data(:,1)>=2003 & master.data(:,1)<=2013);
data_out = repmat(NaN,length(ind),length(to_load));
for i = 1:1:length(to_load)
   if ~isnan(to_load{i,2})
       data_out(:,i) = master.data(ind,to_load{i,2});
   end
    
end

%%% Fill in the rest of the information:
for i = 2003:1:2013
   [tmp] = params(i, 'TP39', 'Heights');
   data_out(data_out(:,1)==i,14)=tmp(1);
   data_out(data_out(:,1)==i,15)=tmp(2).*2./3;
   data_out(data_out(:,1)==i,16)=tmp(2);
end

%%% Save the data:
csvwrite_with_headers('/1/fielddata/Matlab/Data/Distributed/FLUXNET_Footprint/CA-TP4_2003_2013.csv',data_out,to_load(:,1));

%% TPD
to_load = { ...
'Year',1; ...
'Month',2; ...
'Day',3; ...
'Hour',4; ...
'Minute',5; ...
'dtime',6; ...
'WS [m s-1]',85; ...
'USTAR [m s-1]',11; ...
'WD [degree]',43; ...
'SIGMA_W [m s-1]',116; ...
'SIGMA_V [m s-1]',117; ...
'TA [degree C]',82; ...
'RH [%]',83; ...
'INST_HEIGHT [m]',NaN; ...
'D [m]',NaN; ...
'HEIGHTC [m]',NaN; ...
'NEE [umol CO2 m-2 s-1]',7; ...
'LE [W m-2]',9; ...
'H [W m-2]',10; ...
};

load('/1/fielddata/Matlab/Data/Master_Files/TPD/TPD_data_master.mat')
master.labels = cell(master.labels);
% Index wanted years:
ind = find(master.data(:,1)>=2012 & master.data(:,1)<=2013);
data_out = repmat(NaN,length(ind),length(to_load));
for i = 1:1:length(to_load)
   if ~isnan(to_load{i,2})
       data_out(:,i) = master.data(ind,to_load{i,2});
   end
    
end

%%% Fill in the rest of the information:
for i = 2012:1:2013
   [tmp] = params(i, 'TPD', 'Heights');
   data_out(data_out(:,1)==i,14)=tmp(1);
   data_out(data_out(:,1)==i,15)=tmp(2).*2./3;
   data_out(data_out(:,1)==i,16)=tmp(2);
end

%%% Save the data:
csvwrite_with_headers('/1/fielddata/Matlab/Data/Distributed/FLUXNET_Footprint/CA-TPD_2012_2013.csv',data_out,to_load(:,1));



% 
% master.data = master.data(master.data(:,1)>=2003 & master.data(:,1)<=2013,:); 
% % Keep the first 
% 
% 
% to_load = [107;11;55;154;NaN;104;105]
% 
% 
% % We need sigma_v
% % Extract mean canopy height, zero-plane displacement height:
