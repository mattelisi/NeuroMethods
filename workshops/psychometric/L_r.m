function L = L_r(x, r, mu, sigma)
%
% log-likelihood of the psychometric function defined in p_r1.m
%

L = sum(log(p_r1(x(r==1), mu, sigma))) + sum(log(1 - p_r1(x(r==0), mu, sigma)));