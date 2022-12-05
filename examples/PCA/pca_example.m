% PCA

clear all; close all

% generate correlated variables
x1 =randn(250,1);
x2 =x1 +randn(250,1);

% plot them
scatter(x1,x2);

% combine and claculate the variance-covariance matrix
X = [x1,x2]';
Sigma = (1/250).*X*X';

% calculate eigenvectors and eigenvalues
[v, lambda] = eig(Sigma);

% sort eigenvectors according to eigenvalues
[lambda, ord] = sort(diag(lambda));
lambda = flip(lambda); ord=flip(ord);
v = v(:,ord);

% v(:,1) is the first principal component
% accounting for the largest fraction of variance in the data
v(:,1)

% plot the first principal component, scaled by eigenvalue
arrow([0,0],v(:,1)*lambda(1), 'linewidth',2);