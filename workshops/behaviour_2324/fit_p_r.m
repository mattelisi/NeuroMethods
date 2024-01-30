function [alpha, beta, L] = fit_p_r(x,r, alpha0, beta0)
%
% fit psychometric function
% Matteo Lisi 2022
%

% initial parameters
if nargin < 4; beta0 = mean(abs(x))/10; end
if nargin < 3; alpha0 =  mean(x); end

% options
options = optimset('Display', 'off') ;

% create 'objective' function to be minimized (the negative of the log-likelihood)
% I use an anonymous function (https://uk.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html)
fun = @(par) -L_r(x, r, par(1), par(2));

% this command do the optimization 
[par, L] = fminsearch(fun,[alpha0, beta0], options);

% output parameters & loglikelihood
alpha = par(1); 
beta = par(2);
L = -L;