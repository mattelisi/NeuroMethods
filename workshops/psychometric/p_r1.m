function p = p_r1(x,mu,sigma)
%
% probability of response x=1 for a cumulative 
% Gaussian psychometric function
% Matteo Lisi 2020

p = (1/2).*(1 + erf((x-mu)./(sqrt(2)*sigma)) );