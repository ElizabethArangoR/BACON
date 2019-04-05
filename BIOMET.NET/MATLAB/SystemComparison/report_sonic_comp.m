function variable_info = report_var
% variable_info = report_var
%
% Generates fcrn_plot_comp setup:
% This is the list of variables that will be plotted, 
% four at a time in a four panel graph in the order 
% given in this function
% The three entries per variable are 
% the fieldName, the variableName and the variableUnit

disp('Comparing sonics');

% Four plots per panel
variable_info = [...
     {'Cov(3,4)','wT','K m s^{-1}'}',...
      {'Cov(1,3)','wu','m^{2} s^{-2}'}',...
      {'Cov(3,3)','sigma_W','m s^{-1}'}',...
      {'Cov(4,4)','sigma_T','^oC'}',...
     {'MiscVariables.CupWindSpeed3D','u_3D','m/s'}',...
      {'MiscVariables.WindDirection','Wind_direction','^o'}',...
      {'Avg(3)','w_avg','m/s'}',...
      {'Avg(4)','Ts_avg','m/s'}',...
   ];

% For plotting replace the underscore
variable_info(4,:) = strrep(variable_info(2,:),'_','\_');
