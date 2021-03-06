function [HH_climate_stats,HH_diag_stats,Time_vector_HH_HH,bVol,cTCHTemp,pTCHTemp] = ach_HH_climate_stats(SiteFlag,...
    data_HH_reordered,data_HF_reordered,Time_vector_HH,Time_vector_HF,...
    co2_ppm_short,temperature,pressure,c);
%Function that computes half-hourly climate and diagnostic stats for automated respiration chamber systems
%Called within: ach_calc - Site dependent
%
%[HH_climate_stats,HH_diag_stats,Time_vector_HH_HH,bVol,cTCHTemp,pTCHTemp] = ach_HH_climate_stats...
%                                      (SiteFlag,data_HH_reordered,data_HF_reordered,Time_vector_HH,...
%                                      Time_vector_HF,co2_ppm_short,temperature,pressure,c);
%
%Input variables:    SiteFlag
%                    data_HH_reordered
%                    data_HF_reordered
%                    Time_vector_HH
%                    Time_vector_HF
%                    co2_ppm_short
%                    temperature
%                    pressure
%                    c
%
%Output variables:   output structures HH_climate_stats and HH_diag_stats that contains all the 
%                       information about chamber climate and diagnostic stats
%                    Time_vector_HH_HH (48x1)
%                    battery voltage (bVol)
%                    control TCH temperature (cTCHTemp)
%                    pump TCH temperature (pTCHTemp)
%
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: none
warning off;

%compute HH chamber climate stats
Time_vector_HH_HH = floor(Time_vector_HH*48+8/60*48/60/24)/48; 

HH_ind_HH = find(diff(Time_vector_HH_HH)>0)+1;

if HH_ind_HH(1) ~= 1,
    HH_ind_HH = [1 ;HH_ind_HH(:)];
end

%compute data for SOA and SOBS systems (CR10, 21X, systemType == 1)
if (upper(SiteFlag) == 'PA' & c.chamber.systemType == 1) | (upper(SiteFlag) == 'BS' & c.chamber.systemType == 1)
    
    Time_vector_HH_HH = Time_vector_HH_HH(HH_ind_HH(2:end));
    numOfHHours_HH = length(Time_vector_HH_HH);
    data_HH_tmp = data_HH_reordered(:,6:c.chamber.chans_CR10);
    
    for i = 1:numOfHHours_HH;
        
        for ch = 1:c.chamber.chNbr
            ind = HH_ind_HH(i):HH_ind_HH(i+1); 
            
            if ~isempty(ind)
                %chamber air temperature 
                HH_climate_stats.temp_air(i,ch) = mean(data_HH_tmp(ind,ch+((ch-1)*3))); 
                %chamber soil surface temperature
                HH_climate_stats.temp_sur(i,ch) = mean(data_HH_tmp(ind,(ch+((ch-1)*3))+1));  
                %chamber soil 2cm temperature
                HH_climate_stats.temp_2cm(i,ch) = mean(data_HH_tmp(ind,(ch+((ch-1)*3))+2));
                
                %chamber PAR at SOBS
                if SiteFlag == 'BS' & c.chamber.chans_CR10 > 31 
                    HH_climate_stats.ppfd(i,1)  = mean(data_HH_tmp(ind,26)); % PAR CH1
                    HH_climate_stats.ppfd(i,2)  = mean(data_HH_tmp(ind,27)); % PAR CH2
                    HH_climate_stats.ppfd(i,3)  = mean(data_HH_tmp(ind,25)); % PAR CH3
                end
                
                %battery voltage
                bVol(i,:) = mean(data_HH_reordered(ind,4));
                %bontrol TCH temperature
                cTCHTemp(i,:) = mean(data_HH_reordered(ind,5));
                %bump TCH temperature
                pTCHTemp(i,:) = mean(data_HH_reordered(ind,29));
                
            end               
            
        end
        
    end
    
    %compute data for SOJP system (CR23X)
elseif upper(SiteFlag) == 'JP'  
    
    numOfHHours_HH = length(Time_vector_HH_HH);                               
    data_thermocouple = data_HH_reordered(:,17:34); % AVG
    
    for i = 1:numOfHHours_HH;
        
        for ch = 1:c.chamber.chNbr
            %chamber air temperature 
            HH_climate_stats.temp_air(i,ch) = data_thermocouple(i,ch+((ch-1)*2));  
            %chamber soil 2cm temperature inside chamber 
            HH_climate_stats.temp_sur(i,ch) = data_thermocouple(i,(ch+((ch-1)*2))+1); 
            %chamber soil 2cm temperature outside chamber
            HH_climate_stats.temp_2cm(i,ch) = data_thermocouple(i,(ch+((ch-1)*2))+2); 
            
            %chamber PAR
            HH_climate_stats.ppfd(i,1) = data_HH_reordered(i,121); % PAR CH3 
            HH_climate_stats.ppfd(i,2) = data_HH_reordered(i,122); % PAR CH4
            
            %battery voltage
            bVol(i,:) = data_HH_reordered(i,5);     % AVG
            %control TCH temperature
            cTCHTemp(i,:) = data_HH_reordered(i,6); % AVG
            %pump TCH temperature
            pTCHTemp(i,:) = data_HH_reordered(i,7); % AVG
            
        end
        
    end
    
    %compute data for SOBS system (CR23X, systemType == 2)
elseif upper(SiteFlag) == 'BS' & c.chamber.systemType ==2
    
    numOfHHours_HH = length(Time_vector_HH_HH);                               
    data_thermocouple = data_HH_reordered(:,17:40); % AVG
    
    for i = 1:numOfHHours_HH;
        
        for ch = 1:c.chamber.chNbr
            
            %chamber air temperature 
            HH_climate_stats.temp_air(i,ch) = data_thermocouple(i,ch+(ch-1));  
            %chamber soil 2cm temperature
            HH_climate_stats.temp_soil(i,ch) = data_thermocouple(i,ch+(ch-1)+1); 
            
            if length(data_HH_reordered) == 172  
                %chamber root exclusion VWC
                HH_climate_stats.vwc(i,1) = data_HH_reordered(i,149); % VWC CH7  - Control (AVG)
                HH_climate_stats.vwc(i,2) = data_HH_reordered(i,150); % VWC CH10 - Control (AVG)
                HH_climate_stats.vwc(i,3) = data_HH_reordered(i,151); % VWC CH9  - root exclusion (AVG)
                HH_climate_stats.vwc(i,4) = data_HH_reordered(i,152); % VWC CH8  - root exclusion (AVG)
                
                %chamber PAR
                HH_climate_stats.ppfd(i,1) = data_HH_reordered(i,165); % PAR CH5, 6 (AVG) 
                HH_climate_stats.ppfd(i,2) = data_HH_reordered(i,166); % PAR CH8, 9 and 10 (AVG)
            end
            
            if length(data_HH_reordered) == 180
                %chamber root exclusion VWC
                HH_climate_stats.vwc(i,1) = data_HH_reordered(i,149); % VWC CH7  - Control (AVG)
                HH_climate_stats.vwc(i,2) = data_HH_reordered(i,150); % VWC CH10 - Control (AVG)
                HH_climate_stats.vwc(i,3) = data_HH_reordered(i,151); % VWC CH9  - root exclusion (AVG)
                HH_climate_stats.vwc(i,4) = data_HH_reordered(i,152); % VWC CH8  - root exclusion (AVG)
                
                %chamber PAR
                HH_climate_stats.ppfd(i,1) = data_HH_reordered(i,165); % PAR CH5, 6 (AVG) 
                HH_climate_stats.ppfd(i,2) = data_HH_reordered(i,166); % PAR CH8, 9 and 10 (AVG)
                HH_climate_stats.ppfd(i,3) = data_HH_reordered(i,167); % PAR CH11, 12 (AVG) 
                HH_climate_stats.ppfd(i,4) = data_HH_reordered(i,168); % PAR CH2, 3 and 4 (AVG)
            end
            
            %battery voltage
            bVol(i,:) = data_HH_reordered(i,5);     % AVG
            %control TCH temperature
            cTCHTemp(i,:) = data_HH_reordered(i,6); % AVG
            %pump TCH temperature
            pTCHTemp(i,:) = data_HH_reordered(i,7); % AVG
            
        end
        
    end
    
    %compute data for SOA system (CR23X, systemType == 2)
elseif upper(SiteFlag) == 'PA' & c.chamber.systemType ==2
    
    numOfHHours_HH = length(Time_vector_HH_HH);                               
    data_thermocouple = data_HH_reordered(:,17:40); % AVG
    
    for i = 1:numOfHHours_HH;
        
        for ch = 1:c.chamber.chNbr
            
            %			AirTemp = mean(data_thermocouple(i,[6 8 10]));
            Temp = data_thermocouple(i,[6 8 10]);
            ind = find(Temp ~= -99999);
            AirTemp = mean(Temp(ind));
            
            %chamber air temperature 
            HH_climate_stats.temp_air(i,ch) = AirTemp;  
            %chamber soil 2cm temperature
            HH_climate_stats.temp_soil(i,1) = data_thermocouple(i,3); %Bole temp - South side 
            HH_climate_stats.temp_soil(i,2) = data_thermocouple(i,5); 
            HH_climate_stats.temp_soil(i,3) = data_thermocouple(i,7); 
            HH_climate_stats.temp_soil(i,4) = data_thermocouple(i,9); 
            HH_climate_stats.temp_soil(i,5) = data_thermocouple(i,11); 
            HH_climate_stats.temp_soil(i,6) = data_thermocouple(i,12); 
            HH_climate_stats.temp_soil(i,7) = data_thermocouple(i,13); 
            HH_climate_stats.temp_soil(i,8) = NaN; 
            HH_climate_stats.temp_soil(i,9) = NaN; 
            HH_climate_stats.temp_soil(i,10) = NaN; 
            HH_climate_stats.temp_soil(i,11) = NaN; 
            HH_climate_stats.temp_soil(i,12) = NaN; 
            
            %battery voltage
            bVol(i,:) = data_HH_reordered(i,5);     % AVG
            %control TCH temperature
            cTCHTemp(i,:) = data_HH_reordered(i,6); % AVG
            %pump TCH temperature
            pTCHTemp(i,:) = data_HH_reordered(i,7); % AVG
            
        end
        
    end
    
    %compute data for SOA system (CR23X, systemType == 2)
elseif upper(SiteFlag) == 'YF' & c.chamber.systemType ==2
    
            %chamber air temperature - use the average for all chambers
            T_air_main = mean(data_HH_reordered(:,c.chamber.Chan_temp_air),2);
            HH_climate_stats.temp_air = T_air_main * ones(1,c.chamber.chNbr);
            %chamber soil 2cm temperature
            HH_climate_stats.temp_soil = NaN .* ones(length(Time_vector_HH_HH),c.chamber.chNbr);
            HH_climate_stats.temp_soil(:,1:length(c.chamber.Chan_temp_soil)) = data_HH_reordered(:,c.chamber.Chan_temp_soil); 
            
            %battery voltage
            bVol = data_HH_reordered(:,c.chamber.Chan_bVol);     % AVG
            %control TCH temperature
            cTCHTemp = data_HH_reordered(:,c.chamber.Chan_cTCHTemp); % AVG
            %pump TCH temperature
            pTCHTemp = data_HH_reordered(:,c.chamber.Chan_pTCHTemp); % AVG
            
            tmp_clim = data_HH_reordered(:,c.chamber.Chan_misc_climate);
            for i = 1:length(c.chamber.Names_misc_climate)
                eval(['HH_climate_stats.' char(c.chamber.Names_misc_climate(i)) ' = tmp_clim(:,i);']);
            end
            
    
end

%compute HH chamber diagnostic stats
%create half-hour time vector from high frequency time vector 
Time_vector_HH_HF = floor(Time_vector_HF*48+8/60*48/60/24)/48;  

HH_ind_HF = find(diff(Time_vector_HH_HF)>0)+1;
if HH_ind_HF(1) ~= 1,
    HH_ind_HF = [1 ;HH_ind_HF(:)];
end

Time_vector_HH_HF = Time_vector_HH_HF(HH_ind_HF(2:end));
numOfHHours_HF = length(Time_vector_HH_HF);

%prepare variable structures
co2 = NaN * ones(numOfHHours_HF,3); 
temp  = co2;
press = co2;
flow  = co2;

for i = 1:numOfHHours_HF;
    ind = HH_ind_HF(i):HH_ind_HF(i+1); 
    if ~isempty(ind) 
        HH_diag_stats.co2(i,1)   = mean(co2_ppm_short(ind));  				%store co2 ppm short avg
        HH_diag_stats.co2(i,2)   = max(co2_ppm_short(ind));
        HH_diag_stats.co2(i,3)   = min(co2_ppm_short(ind));
        HH_diag_stats.temp(i,1)  = mean(temperature(ind));    				%store optical bench temperature avg   
        HH_diag_stats.temp(i,2)  = max(temperature(ind));
        HH_diag_stats.temp(i,3)  = min(temperature(ind));
        HH_diag_stats.press(i,1) = mean(pressure(ind));       				%store licor pressure avg
        HH_diag_stats.press(i,2) = max(pressure(ind));
        HH_diag_stats.press(i,3) = min(pressure(ind));  
        HH_diag_stats.flow(i,1)  = mean(data_HF_reordered(ind,11));     %store MFC flow rate avg                   
        HH_diag_stats.flow(i,2)  = max(data_HF_reordered(ind,11));                   
        HH_diag_stats.flow(i,3)  = min(data_HF_reordered(ind,11));                   
    end                
end
