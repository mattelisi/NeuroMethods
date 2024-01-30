function p = p_r1(x,alpha,beta)
%
% probability of response x=1 for a logistic psychometric function
% Matteo Lisi 2020

p = 1./(1 + exp(-beta*(x-alpha)));