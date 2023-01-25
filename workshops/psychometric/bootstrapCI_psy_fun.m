function [out] = bootstrapCI_psy_fun(mu,sigma, stim_levels, nSim)
% boostrap CI for psy fun parameters
%
% Note:
% - nSim is the number of bootstrap iterations
%
% Matteo Lisi, 2020

if nargin < 4
    nSim = 10^4;
end

boot_mu = NaN(nSim,1);
boot_sigma = NaN(nSim,1);

levels_prob = p_r1(stim_levels, mu, sigma);

% loop
for i=1:nSim
    sim_data = binornd(1 ,levels_prob); % simulate data
    [mu_i, sigma_i, ~] = fit_p_r(stim_levels, sim_data); % refit
    boot_mu(i) = mu_i;
    boot_sigma(i) = sigma_i;
end

out.mu.CI = prctile(boot_mu,[5,95]);
out.mu.SE = std(boot_mu);

out.sigma.CI = prctile(boot_sigma,[5,95]);
out.sigma.SE = std(boot_sigma);


end