% script analysis behaviour
clear all

%% visualize sigmoid function
x = linspace(1, 40, 100);
psy_fun = @(alpha,beta) 1./(1 + exp(-beta*(x-alpha)));

% set parameters for plotting the function
alpha_value = 15;
beta_value = 1;

% plot
plot(x, psy_fun(alpha_value, beta_value),'-','Color',[1 0.2 0.0],'LineWidth',3);

hold on

% change alpha, the function moves horizontally
plot(x, psy_fun(alpha_value+10, beta_value),'-','Color',[0 0 1],'LineWidth',2)

% decrease slope beta, function get more shallow
plot(x, psy_fun(alpha_value, beta_value/10),'--','Color',[1 0.2 0.0],'LineWidth',2)

hold off

%% load data
opts = detectImportOptions('discounting_1sj.csv');
preview('discounting_1sj.csv',opts)
D  = readtable('discounting_1sj.csv', opts);

% table values can be accessed in the following ways
D.immediate

% calculate difference between delayed and immediate reward choices
D.diff = D.delayed - D.immediate;


% plot stimuli
h = scatter(D.immediate,  D.delayed,50,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0.5 0.5 1]);
line([0,100],[0,100],'LineWidth',0.2,'LineStyle','--');
xlabel('Immediate reward (£)');
ylabel('Delayed reward (£)');
xlim([5,50]); 
ylim([5 50]);

%% Plot raw data

% calculate averages and standard errors
stim = unique(D.diff);
nTrials = NaN(size(stim));
pChooseDelayed = NaN(size(stim));
pChooseDelayed_se = NaN(size(stim));
for cc = 1:length(stim)
    nTrials(cc) = sum(D.diff==stim(cc));
    pChooseDelayed(cc) = mean(D.choose_delayed(D.diff==stim(cc)));
    pChooseDelayed_se(cc) = sqrt(pChooseDelayed(cc) * (1-pChooseDelayed(cc))) / nTrials(cc);
end

% make plot
h = scatter(stim, pChooseDelayed,50,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);
set(gcf,'color','w');
hold on
line([1,45],[0.5,0.5],'LineWidth',0.2,'LineStyle','--');
for cc = 1:length(stim)
    plot([stim(cc),stim(cc)],[pChooseDelayed(cc)-pChooseDelayed_se(cc), pChooseDelayed(cc)+pChooseDelayed_se(cc)],'Color',[0 0 1],'LineWidth',2);
end
hold off

% add labelling 
xlabel('Difference between delayed and immediate reward (£)');
ylabel('Proportion of "delayed reward" choices');
xlim([min(stim),max(stim)]); 
ylim([0 1]);

%% fit psychometric function
[alpha, beta, L] = fit_p_r(D.diff, D.choose_delayed);

% add psychometric function to plot
stim_fine = linspace(min(stim), max(stim),500)';
pred_prob = p_r1(stim_fine, alpha, beta);

hold on
plot(stim_fine, pred_prob,'-','Color',[1 0.2 0.0],'LineWidth',3);

% add line to indicate point of "perceptual indifference"
% referred to as point of subjective equality or PSE
line([alpha, alpha],[0,0.5],'Color',[1 0.2 0.0],'LineWidth',1.5,'LineStyle','--');

hold off


%% bootstrap
[out] = bootstrapCI_psy_fun(alpha, beta, D.diff, 10000);
out.alpha
out.beta

% add CI for alpha on plot
hold on
line(out.alpha.CI, [0.5,0.5],'Color',[1 0.2 0.0],'LineWidth',7);
hold off


%% visualize the likelihood function
[X,Y] = meshgrid(linspace(5, 15,100),linspace(-0.5, 1,100));
F = arrayfun(@(xi,yi) exp(L_r(D.diff, D.choose_delayed, xi, yi)), X, Y);
surf(X,Y,F);
shading flat
xlabel('alpha');
zlabel('likelihood');
ylabel('beta');

[X,Y] = meshgrid(linspace(5, 15,100),linspace(-0.5, 1,100));
F = arrayfun(@(xi,yi) L_r(D.diff, D.choose_delayed, xi, yi), X, Y);
surf(X,Y,F);
xlabel('alpha');
zlabel('log-likelihood');
ylabel('beta');

% change view
view(2)
shading interp
hold on
plot3(mu, sigma,max(F(:)),'ko')
hold off

%% exercises

% Repeat the analysis for each participants in this dataset.
% participants labelled with PD are patients with Parkinson on dopaminergic medication (known to affect reward processing)
% participants labelled with CT are healthy controls (comparison group)
opts = detectImportOptions('discounting_all.csv');
preview('discounting_all.csv',opts)
D_all  = readtable('discounting_all.csv', opts);

D_all.diff = D_all.delayed - D_all.immediate;

% get number of participants
N_sj = length(unique(D_all.subjectID));
ID_sj = unique(D_all.subjectID);

alpha_all = NaN(N_sj, 1);
beta_all = NaN(N_sj, 1);
patient = NaN(N_sj, 1);

for i = 1:length(ID_sj)
     
    x = D_all.diff(strcmp(D_all.subjectID,ID_sj(i)));
    y = D_all.choose_delayed(strcmp(D_all.subjectID,ID_sj(i)));

    [alpha_i, beta_i, ~] = fit_p_r(x,y);
    
    alpha_all(i) = alpha_i;
    beta_all(i) = beta_i;

    group_i = unique(D_all.group(strcmp(D_all.subjectID,ID_sj(i))));
    patient(i) = strcmp(group_i, 'PD');
end



