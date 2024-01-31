function [out] = bootstrapCI_psy_fun(alpha, beta, stim_levels, nSim)
% boostrap CI for psy fun parameters
%
% Note:
% - nSim is the number of bootstrap iterations
%
% Matteo Lisi, 2020

if nargin < 4
    nSim = 10^4;
end

boot_alpha = NaN(nSim,1);
boot_beta = NaN(nSim,1);

levels_prob = p_r1(stim_levels, alpha, beta);

% loop
for i=1:nSim
    sim_data = binornd(1 ,levels_prob); % simulate data
    [alpha_i, beta_i, ~] = fit_p_r(stim_levels, sim_data); % refit
    boot_alpha(i) = alpha_i;
    boot_beta(i) = beta_i;
end

out.alpha.CI = prctile(boot_alpha,[2.5,97.5]);
out.alpha.SE = std(boot_alpha);
out.alpha.boot_alpha = boot_alpha;

out.beta.CI = prctile(boot_beta,[2.5,97.5]);
out.beta.SE = std(boot_beta);
out.beta.boot_beta = boot_beta;

end