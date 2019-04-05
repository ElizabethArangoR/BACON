clear all;

path_start = '/1/fielddata/Matlab/Scripts/';


dirs = {'mcm_data_mgmt/';...
    'Curve_Fitting/fitGEP/';...
'Curve_Fitting/fitresp/';...
'Data_Filling/';...
'Error/';...
'Flux/';...
'Footprint/';...
'Gapfilling/';...
'mcm_Gapfill/';...
'genfuns/';...
'Met/';...
'Sunrise/';...
'Averaging/'};

output = {};

for j = 1:1:size(dirs,1)
d = dir([path_start dirs{j,1}]);

for i = 3:1:length(d)
    
    [pathstr, name, ext, versn] = fileparts(d(i).name);
    
    if strcmpi(ext,'.m')==1 && strncmp(d(i).name,'old',3)~=1
       [s result] = unix(['wc -l ' path_start dirs{j,1} d(i).name]);
       a = strfind(result,'/');
       len = str2double(result(1:a(1)-1)); 
       output{size(output,1)+1,1} = d(i).name;
       output{size(output,1),2} = len;
       
       clear a len
    end
end

end

num_scripts = size(output,1);
num_lines = sum(cell2mat(output(:,2)));

