function p = p_r1(x,mu,sigma)
%
% probability of response x=1 for a cumulative 
% Gaussian psychometric function
<<<<<<< HEAD
=======
% Matteo Lisi 2020
>>>>>>> 92590089d7d2afb083cd10b461486893107ee30c

p = (1/2).*(1 + erf((x-mu)./(sqrt(2)*sigma)) );