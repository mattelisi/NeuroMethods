% script analysis behaviour
clear all

%% visualize cumulative Gaussian function
x = linspace(1, 21, 100);
psy_fun = @(mu, sigma) (1/2).*(1 + erf((x-mu)./(sqrt(2)*sigma)) );

% set parameters for plotting the function
mu_value = 11;
sigma_value = 1;

% plot
plot(x, psy_fun(mu_value, sigma_value),'-','Color',[1 0.2 0.0],'LineWidth',3);

hold on

% change mu, the function moves horizontally
plot(x, psy_fun(mu_value-4, sigma_value),'-','Color',[0 0 1],'LineWidth',2)

% increase sigma, the slope becomes shallower
plot(x, psy_fun(mu_value, sigma_value+5),'--','Color',[1 0.2 0.0],'LineWidth',2)

hold off

%% load data
opts = detectImportOptions('emo_recognition_1subject.csv');
preview('emo_recognition_1subject.csv',opts)
D  = readtable('emo_recognition_1subject.csv', opts);

% table values can be accessed in the following ways
%D(:,'morph_level');
D.morph_level;

% recoder responses sa 'sad' choices
D.resp_sad = 1 - D.resp_happy;

%% Plot raw data

% calculate averages and standard errors
stim = unique(D.morph_level);
nTrials = NaN(size(stim));
pSad = NaN(size(stim));
pSad_se = NaN(size(stim));
for cc = 1:length(stim)
    nTrials(cc) = sum(D.morph_level==stim(cc));
    pSad(cc) = mean(D.resp_sad(D.morph_level==stim(cc)));
    pSad_se(cc) = sqrt(pSad(cc) * (1-pSad(cc))) / nTrials(cc);
end

% make plot
h = scatter(stim, pSad,50,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);
set(gcf,'color','w');
hold on
line([11,11],[0,1],'LineWidth',0.2,'LineStyle','--');
line([1,21],[0.5,0.5],'LineWidth',0.2,'LineStyle','--');
for cc = 1:length(stim)
    plot([stim(cc),stim(cc)],[pSad(cc)-pSad_se(cc), pSad(cc)+pSad_se(cc)],'Color',[0 0 1],'LineWidth',2);
end
hold off

% add labelling 
xlabel('Face morphing [happy > sad]');
ylabel('Proportion responses "sad"');
xlim([min(stim),max(stim)]); 
ylim([0 1]);

%% fit psychometric function
[mu, sigma, L] = fit_p_r(D.morph_level, D.resp_sad);

% add psychometric function to plot
stim_fine = linspace(min(stim), max(stim),100)';
pred_prob = p_r1(stim_fine, mu, sigma);

hold on
plot(stim_fine, pred_prob,'-','Color',[1 0.2 0.0],'LineWidth',3);

% add line to indicate point of "perceptual indifference"
% referred to as point of subjective equality or PSE
line([mu,mu],[0,0.5],'Color',[1 0.2 0.0],'LineWidth',1.5,'LineStyle','--');

hold off



%% bootstrap
[out] = bootstrapCI_psy_fun(mu,sigma, D.morph_level, 1000);
out.mu
out.sigma

% add CI for MU on plot
hold on
line(out.mu.CI, [0.5,0.5],'Color',[1 0.2 0.0],'LineWidth',7);
hold off


%% visualize the likelihood function
[X,Y] = meshgrid(linspace(5, 15,100),linspace(0.1, 5,100));
F = arrayfun(@(xi,yi) exp(L_r(D.morph_level, D.resp_sad, xi, yi)), X, Y);
surf(X,Y,F);
shading flat
xlabel('mu');
zlabel('likelihood');
ylabel('sigma');

% [X,Y] = meshgrid(linspace(8, 11,50),linspace(0.5, 4,50));
% F = arrayfun(@(xi,yi) exp(L_r(D.morph_level, D.resp_sad, xi, yi)), X, Y);
% surf(X,Y,F);
% % shading flat
% xlabel('mu');
% zlabel('likelihood');
% ylabel('sigma');
% xlim([8,11]); 
% ylim([0.5,4]); 

% change view
view(2)
shading interp
hold on
plot3(mu, sigma,max(F(:)),'ko')
hold off

%% exercises

% 1) repeat with a noisy participants and see how the log-likelihood
% function changes 
D  = readtable('emo_recognition_1subject_less data.csv', opts);


% 2) here is a participant that also make some random errors: how can the
% approach above be adapted to take this into account?
D  = readtable('emo_recognition_1subject_lapses.csv', opts);

