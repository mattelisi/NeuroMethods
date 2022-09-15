%
% dual-decision task
%

%clear all;  clear mex;  clear functions;
addpath('functions/');

home;

%% general parameters
const.gammaLinear = 0;      % use monitor linearization

% % gamma calibration data folders path
% const.gamma    = '../gammacalib/Eyelink.mat';
% load(const.gamma);
% minLum = 255*(minLum - LR.LMin)/(LR.LMax - LR.LMin);

% random number generator stream (r2010a default, different command for r2014a)
% this is needed only for matlab (where the random number generator start always at the same state)
% in octave the generator is initialized from /dev/urandom (if available) otherwise from CPU time,
% wall clock time, and the current fraction of a second.
rng('shuffle');

%% participant informations
% collect data and, if duplicate, check before overwriting
newFile = 0;

while ~newFile
    [vpcode, dual_decision] = getVpCode;

    % create data file
    datFile = sprintf('%s.mat',vpcode);
    
    % dir names
    subDir=vpcode(1:4);
    sessionDir=vpcode(5:6);
    resdir=sprintf('data/%s/%s',subDir,sessionDir);
    
    if exist(resdir,'file')==7
        o = input('\n\n         This directory exists already. Should I continue/overwrite it [y / n]? ','s');
        if strcmp(o,'y')
            % delete files to be overwritten?
            if exist([resdir,'/',datFile])>0;                    delete([resdir,'/',datFile]); end
            if exist([resdir,'/',sprintf('%s',vpcode)])>0;       delete([resdir,'/',sprintf('%s',vpcode)]); end
            newFile = 1;
        end
    else
        mkdir(resdir);
        newFile = 1;
    end
end

%% run
sub_n = str2double(vpcode(1:2));
ses_n = str2double(vpcode(5:6));

design = genDesign(ses_n, sub_n, dual_decision, vpcode);

% prepare screens
scr = prepScreen;

% prepare stimuli
visual = prepStim(scr);

tic;
try
    % runtrials
    design = runTrials(design, vpcode, resdir, scr, visual);
catch ME
    sca;
    rethrow(ME);
end


% save updated design information
save(sprintf('./%s/%s.mat',resdir,vpcode),'design','visual','scr','const');
fprintf(1,'\n\nThis part of the experiment took %.0f min.\n',(toc)/60);

% close
sca;

