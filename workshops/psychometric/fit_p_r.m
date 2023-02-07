function [mu, sigma, L] = fit_p_r(x,r, mu0, sigma0)
%
% fit cumulative Gaussian psychometric function
%

% initial parameters
if nargin < 4; sigma0 = mean(abs(x))/2; end
if nargin < 3; mu0 =  mean(x); end
par0 = [mu0, sigma0];

% options
options = optimset('Display', 'off') ;

% % do optimization
% % the function L_r() is positive
% fun = @(par) -L_r(x, r, par(1), par(2));
% 
% % this command do the optimization 
% [par, L] = fminsearch(fun, [mu0, sigma0], options);
% 
% % output parameters & loglikelihood
% mu = par(1); 
% sigma = par(2);
% L = -L;


% create 'objective' function to be minimized (the negative of the log-likelihood)
% I use an anonymous function (https://uk.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html)
% note also that I exponentiate par(2), that is the sigma, to make sure the value given as input to 
% the function L_r() is positive
fun = @(par) -L_r(x, r, par(1), exp(par(2)));

% this command do the optimization 
[par, L] = fminsearch(fun, [mu0, log(sigma0)], options);

% output parameters & loglikelihood
mu = par(1); 
sigma = exp(par(2));
L = -L;