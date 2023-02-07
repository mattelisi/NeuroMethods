% anti-saccade task; analysis single subject
clear all

addpath('../functions');
addpath('./analysis_functions');

%% settings
scr.subDist = 80;   % subject distance (cm)
scr.width   = 570;  % monitor width (mm)
img_duration = 3;

scr.xres = 1920;
scr.yres = 1080;
scr.xCenter = scr.xres/2;
scr.yCenter = scr.yres/2 ;
ppd = va2pix(1,scr); % pixel per degree


%% import file
% location of raw data file
raw_data = '../data/S2.edf';

% system('edf2asc ../data/S1.edf -s -miss -1.0')

% load eye movement file
ds = edfmex(raw_data); % ,'-miss -1.0'
save('S2_edfstruct.mat', 'ds');

% see the content of the data
ds.FSAMPLE
ds.FEVENT.message

% how many trials? here are the index of img onsets for each trial
find(strcmp({ds.FEVENT.message}, 'EVENT_FixationDot')==1)
