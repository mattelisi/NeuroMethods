function [out] = estimate_noise(vpcode, sess)
%
% Estimate noise using model-averaging to merge different estimates
% with and without free parameter for lapse rate
%
% Matteo Lisi, 2019
%

%% read the data
s_id = vpcode(1:4);

ori_s = []; ori_r = [];
mot_s = []; mot_r = [];

% datFile, b, t, design.dual_decision, design.lines_first,  1/2, design.lines_first, side2, NaN, td.mu, meanTilt, sdTilt, tOn, tOff, rr, acc, tResp,];
% datFile, b, t, design.dual_decision, design.lines_first,  1/2, design.lines_first, side2, td.ch, NaN, NaN, NaN, tOn, tOff, rr, acc, tResp,];

for i = 1:(sess-1)
    
    % get filename
    sess_i = num2str(i);
    if length(sess_i)==1
        sess_i = strcat('0',sess_i);
    end
    filename = sprintf('./data/%s/%s/%s%s',s_id,sess_i,s_id,sess_i);
    
    % open it and get the data 
    ifid = fopen(filename,'r');
    while 1
        line = fgetl(ifid);
        if ~ischar(line)    % end of file
            break;
        end
        
        la = strread(line,'%s');
        if isnan(str2double(char(la(9)))) % then orientation
            signed_mu = str2double(char(la(8))) * str2double(char(la(10)));
            ori_s = [ori_s, signed_mu]; 
            ori_r = [ori_r, str2double(char(la(15)))];
        else
            signed_ch = str2double(char(la(8))) * str2double(char(la(9)));
            mot_s = [mot_s, signed_ch]; 
            mot_r = [mot_r, str2double(char(la(15)))];
        end
    end
end

% sanity check
% [mot_s',mot_r',ori_s',ori_r';]

%% analysis orientation
[mu, sigma, ~, ~, AIC] = fit_p_r(ori_s, ori_r);
[mu_0, sigma_0, ~, AIC_0] = fit_p_r_0(ori_s, ori_r);
aic_w = calculate_akaike_weight([AIC, AIC_0]);
bias_ori = aic_w(1)*mu + aic_w(2)*mu_0;
sigma_ori = aic_w(1)*sigma + aic_w(2)*sigma_0;

%% analysis motion
[mu, sigma, ~, ~, AIC] = fit_p_r(mot_s, mot_r);
[mu_0, sigma_0, ~, AIC_0] = fit_p_r_0(mot_s, mot_r);
aic_w = calculate_akaike_weight([AIC, AIC_0]);
bias_mot = aic_w(1)*mu + aic_w(2)*mu_0;
sigma_mot = aic_w(1)*sigma + aic_w(2)*sigma_0;

%% format output
out.motion.bias = bias_mot;
out.motion.sigma = sigma_mot;
out.orientation.bias = bias_ori;
out.orientation.sigma = sigma_ori;

%% store in a mat file
noisefile = sprintf('./data/%s/%s_noise.mat',vpcode(1:4),vpcode(1:4));
save(noisefile, 'out');

end


%-------------------------------------------------------------------------%
%% local functions

function p = p_r(x, mu, sigma, lambda)
% probability of choosing "+" for a cumulative 
% Gaussian with symmetric asymptote
p = lambda + (1-2*lambda)*(1/2)*(1 + erf((x-mu)/(sqrt(2)*sigma)) );
end


function p = p_r_0(x, mu, sigma)
% probability of choosing "+" for a cumulative Gaussian
p = (1/2)*(1 + erf((x-mu)/(sqrt(2)*sigma)) );
end


function L = L_r(x, r, mu, sigma, lambda)
% log-likelihood of the psychometric function defined in p_r
L = sum(log(p_r(x(r==1), mu, sigma, lambda))) + sum(log(1 - p_r(x(r==0), mu, sigma, lambda)));
end


function L = L_r_0(x, r, mu, sigma)
% log-likelihood of the psychometric function defined in p_r_0
L = sum(log(p_r_0(x(r==1), mu, sigma))) + sum(log(1 - p_r_0(x(r==0), mu, sigma)));
end


function [mu, sigma, lambda, L, AIC] = fit_p_r(x,r, mu0, sigma0, lambda0)
%
% fit cumulative Gaussian with symmetric asymptotes (lambda and 1-lambda)
% Matteo Lisi, 2017

% initial parameters
if nargin < 5; lambda0 = 0; end
if nargin < 4; sigma0 = mean(abs(x)); end
if nargin < 3; mu0 = 0; end
par0 = [mu0, sigma0, lambda0];

% options
options = optimset('Display', 'off') ;

% set boundaries
lb = [-3*sigma0,   sigma0/4, 0];
ub = [ 3*sigma0, 4*sigma0, 0.2];

% do optimization
fun = @(par) -L_r(x, r, par(1), par(2), par(3));
[par, L] = fmincon(fun, par0, [],[],[],[], lb, ub,[],options);

% output parameters & loglikelihood
mu = par(1); 
sigma = par(2);
lambda = par(3);
L = -L;
AIC = 2*3 - 2*L;
end


function [mu, sigma, L, AIC] = fit_p_r_0(x,r, mu0, sigma0)
%
% fit cumulative Gaussian 
% Matteo Lisi, 2017

% initial parameters
if nargin < 4; sigma0 = mean(abs(x)); end
if nargin < 3; mu0 = 0; end
par0 = [mu0, sigma0];

% options
options = optimset('Display', 'off') ;

% set boundaries
lb = [-3*sigma0, sigma0/4];
ub = [ 3*sigma0, 4*sigma0];

% do optimization
fun = @(par) -L_r_0(x, r, par(1), par(2));
[par, L] = fmincon(fun, par0, [],[],[],[], lb, ub,[],options);

% output parameters & loglikelihood
mu = par(1); 
sigma = par(2);
L = -L;
AIC = 2*2 - 2*L;
end


function[aic_w] = calculate_akaike_weight(aic)
% calculate Akaike weight; aic and aic_w are vectors
aic_w = aic - min(aic);
aic_w = exp(-0.5 * aic_w);
aic_w = aic_w/sum(aic_w);
end
