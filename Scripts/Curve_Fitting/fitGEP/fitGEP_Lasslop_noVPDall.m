function out = fitGEP_Lasslop_noVPDall(c_hat,x)
%%
%%% fitGEP_Lasslop_noVPDall.m
%%% This function estimates NEE (not GEP) using the MM rectangular
%%% hyperbolic function and subtracting RE (using the L&T method, with 
%%% two flexible parameters -- rb [a.k.a. Rref] and Eo).
%%% The Eo parameter is derived from daytime data.
%%% input: x (X) inputted as [PAR T]

global X Y stdev objfun fixed_coeff coeffs_to_fix;

%%% Fix coefficient values if specified:
%%% Modified 4-Dec-2010:  
%%% When we have fixed coefficients, the coefficients that are fed into 
%%% this function (c_hat), does not include the fixed coefficient (or else
%%% it would get adjusted by fminsearch, fmincon, etc...).However, we need
%%% that value in the proper place in c_hat, so that the function can be
%%% evaluated properly.  Therefore, we need to put it back into the right
%%% spot in c_hat, and evaluate the function, 
%%% We do not have to put it back in, as the only output is the cost
%%% function value.  Still with me?  Good.
%%% Put the coefficient in the right spot in c_hat for evaluation purposes:
if sum(coeffs_to_fix) > 0
    c_tmp = fixed_coeff;
    c_tmp(coeffs_to_fix==0) = c_hat(1:end);
    clear c_hat;
    c_hat = c_tmp;
    clear c_tmp;
end

%% Evaluation:
%%% If nargin > 1, we want to evaluate with an x value that's been inputted
%%% by the user for final evaluation purposes.  Otherwise, the evaluation
%%% is being done by the optimization function (one argument required):



if nargin > 1
%        y_hat = ( (c_hat(1)*c_hat(2)*x(:,1))./(c_hat(1)*x(:,1) + c_hat(2)) ) + ...
%            c_hat(3).*exp(c_hat(4).*( (1./(10-(-46.02))) - (1./(x(:,2)-(-46.02))) ));
       y_hat = c_hat(3).*(exp(c_hat(4).*( (1./(10-(-46.02))) - (1./(x(:,2)-(-46.02)))) )) - ...
           ( (c_hat(1).*c_hat(2).*x(:,1))./(c_hat(1).*x(:,1) + c_hat(2)));       
       out = y_hat;
else
%        y_hat = ( (c_hat(1)*c_hat(2)*X(:,1))./(c_hat(1)*X(:,1) + c_hat(2)) ) + ...
%            c_hat(3).*exp(c_hat(4).*( (1./(10-(-46.02))) - (1./(X(:,2)-(-46.02))) ));
       y_hat = c_hat(3).*(exp(c_hat(4).*( (1./(10-(-46.02))) - (1./(X(:,2)-(-46.02)))) )) - ...
           ( (c_hat(1).*c_hat(2).*X(:,1))./(c_hat(1).*X(:,1) + c_hat(2)) );

switch objfun
    case 'OLS'
        err = sum((y_hat - Y).^2);
    case 'WSS'
        err = sum(((y_hat - Y).^2)./(stdev.^2));
    case 'MAWE'
        err = (1./length(X)) .* ( sum(abs(y_hat - Y)./stdev));
    otherwise
        disp('no objective function specified - using least-squares')
      err = sum((y_hat - Y).^2);
end
out = err;
end
