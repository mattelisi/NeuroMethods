%
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
raw_data = '../data/S1.edf';

% system('edf2asc ../data/S1.edf -s -miss -1.0')

% load eye movement file
ds = edfmex(raw_data); % ,'-miss -1.0'
save('S1_edfstruct.mat', 'ds');

% see the content of the data
ds.FSAMPLE
ds.FEVENT.message

% how many trials? here are the index of img onsets for each trial
find(strcmp({ds.FEVENT.message}, 'EVENT_FixationDot')==1)

%% prepare data

% which eye was tracked?
% 0=left 1=right (add 1 for indexing below)
eye_tracked = 1 + unique([ds.FEVENT.eye]);

% initialize 
trial_n = NaN;
trial_n_2 = NaN;
trial_n_3 = NaN;
t_start = NaN;
t_end =  NaN;
img_onset =  NaN;
img_offset =  NaN;
img_name =  NaN;
fake_image =  NaN;
accuracy =  NaN;
imgRect =  [];
timestamp  =  [];
eye_x =  [];
eye_y =  [];

ds2 = {};
trial_count = 0;
for i = 1:length(ds.FEVENT)
    
    % go through the list of events and extract relevant informations
    if ~isempty(ds.FEVENT(i).message)
        
        % parse string in different "words"
        sa = strread(ds.FEVENT(i).message,'%s');
        
        % onset of trial
        if strcmp(sa(1),'TRIAL_START')
            trial_n = str2double(sa(2));
            t_start = ds.FEVENT(i).sttime;
        end
        
        % image onset
        if strcmp(sa(1),'EVENT_FixationDot')
           img_onset = int32(ds.FEVENT(i).sttime);
           img_offset = img_onset + 3000;
        end
        
        % end of eye movement recoding
        if strcmp(sa(1),'TRIAL_END')
           trial_n_2 = str2double(sa(2));
           t_end = ds.FEVENT(i).sttime;
        end
        
        % data info
        if strcmp(sa(1),'TrialData')
           img_name = sa(5);
           trial_n_3 = str2double(sa(2));
           fake_image = str2double(sa(4));
           accuracy = str2double(sa(7));
           imgRect = [str2double(sa(8:11))]';
        end
    end
    
    % if we have everything, then extract gaze position samples
    if ~isnan(trial_n) && ~isnan(trial_n_2) && ~isnan(trial_n_3)
        
        trial_count = trial_count+1;
        
        % find onset-offset of relevant recording
        index_start = find(ds.FSAMPLE.time==t_start);
        index_end = find(ds.FSAMPLE.time==img_offset + 400);
        
        % timestamp (set 0 for img onset)
        timestamp  =  int32(ds.FSAMPLE.time(index_start:index_end)) - img_onset;
        
        eye_x =  ds.FSAMPLE.gx(eye_tracked, index_start:index_end);
        eye_y =  ds.FSAMPLE.gy(eye_tracked, index_start:index_end);
        
        % remove missing
        eye_x(eye_x==100000000 | eye_y==100000000) = NaN;
        eye_y(eye_y==100000000 | eye_x==100000000) = NaN;
        
        % remove blinks etc
        eye_x(eye_x<0 | eye_x>scr.xres | eye_y<0 | eye_y>scr.yres ) = NaN;
        eye_y(eye_y<0 | eye_y>scr.yres | eye_x<0 | eye_x>scr.xres ) = NaN;
        
        % save ecverything into a single structure
        ds2.trial(trial_count).trial_n = trial_n;
        ds2.trial(trial_count).t_start = t_start;
        ds2.trial(trial_count).t_end = t_end;
        ds2.trial(trial_count).img_onset = img_onset;
        ds2.trial(trial_count).img_name = img_name;
        ds2.trial(trial_count).fake_image = fake_image;
        ds2.trial(trial_count).accuracy = accuracy;
        ds2.trial(trial_count).imgRect =  imgRect;
        ds2.trial(trial_count).timestamp  =  timestamp  ;
        ds2.trial(trial_count).eye_x =  eye_x;
        ds2.trial(trial_count).eye_y =  eye_y;
        
        % re-initialize
        trial_n = NaN;
        trial_n_2 = NaN;
        trial_n_3 = NaN;
        t_start = NaN;
        t_end =  NaN;
        img_onset =  NaN;
        img_offset =  NaN;
        img_name =  NaN;
        fake_image =  NaN;
        accuracy =  NaN;
        imgRect =  [];
        timestamp  =  [];
        eye_x =  [];
        eye_y =  [];
        
    end
    
end
    
%% plot raw data for 1 image
t = 3;

if ds2.trial(t).fake_image ==1
    imgpath = ['../img/fake/', char(ds2.trial(t).img_name)];
else
    imgpath = ['../img/real/', char(ds2.trial(t).img_name)];
end

imshow(imgpath);
C = imread(imgpath);
img_rect = ds2.trial(t).imgRect;
x_scaling = size(C,2)/(img_rect(3) - img_rect(1));
y_scaling = size(C,1)/(img_rect(4) - img_rect(2));

axis on
hold on;

% plot gaze position
XY = [x_scaling*(ds2.trial(t).eye_x - (img_rect(1)-1)); ...
    y_scaling*(ds2.trial(t).eye_y - (img_rect(2)-1))]';

plot(XY(:,1), XY(:,2), 'b', 'MarkerSize', 30, 'LineWidth', 2);

hold off


%% saccade analysis for 1 image
t = 5;

% saccade algorithm parameters
SAMPRATE  = 1000;       % Eyetracker sampling rate 
velSD     = 5;          % lambda for microsaccade detectionc
minDur    = 8;          % threshold duration for microsaccades (ms)
VELTYPE   = 2;          % velocity type for saccade detection
maxMSAmp  = 1;          % maximum microsaccade amplitude
mergeInt  = 10;         % merge interval for subsequent saccadic events


xrs = [];
xrsf = [];
vrs = [];
vrsf= [];

% gaze position samples
XY = [ds2.trial(t).eye_x; ds2.trial(t).eye_y]';

% invert Y coordinates and transform in degrees relative to screen center
xrsf = double((1/ppd) * [XY(:,1)-scr.xCenter, (scr.yCenter-XY(:,2))]);  

% filter eye movement data (mostly for plotting)
xrs(:,1) = movmean(xrsf(:,1),6);
xrs(:,2) = movmean(xrsf(:,2),6);

% compute saccade parameters
vrs = vecvel(xrs, SAMPRATE, VELTYPE);    % velocities
vrsf= vecvel(xrsf, SAMPRATE, VELTYPE);   % velocities

mrs = microsaccMerge(xrsf,vrsf,velSD, minDur, mergeInt);  % saccades
mrs = saccpar(mrs);

% PLOT TRACES
% prepare figure and axes
close all;
cbac = [1.0 1.0 1.0];
h1 = figure;
set(gcf,'color',cbac);
ax(1) = axes('pos',[0.1 0.6 0.85 0.4]); % left bottom width height
ax(2) = axes('pos',[0.1 0.1 0.85 0.4]);

timers = double(ds2.trial(t).timestamp);
timeIndex = (timers - timers(1) +1)/1000;

axes(ax(1));
% plot horizontal position
plot(timeIndex,xrs(:,1),'-','color',[0.8 0 0],'linewidth',1);
hold on
for i = 1:size(mrs,1)
    plot(timeIndex((mrs(i,1):mrs(i,2))), xrs(mrs(i,1):mrs(i,2),1),'-','color',[0.8 0 0],'linewidth',3);
end
% plot vertical position
plot(timeIndex,xrs(:,2),'-','color',[0.2 0.2 0.8],'linewidth',1);
for i = 1:size(mrs,1)
    plot(timeIndex((mrs(i,1):mrs(i,2))), xrs(mrs(i,1):mrs(i,2),2),'-','color',[0 0 0.8],'linewidth',3);
end
ylim([-max(abs(xrs(:))),max(abs(xrs(:)))])
ylabel('position [deg]');

axes(ax(2));
% plot horizontal position
plot(timeIndex,vrs(:,1),'-','color',[0.8 0 0],'linewidth',1);
hold on
for i = 1:size(mrs,1)
    plot(timeIndex((mrs(i,1):mrs(i,2))), vrs(mrs(i,1):mrs(i,2),1),'-','color',[0.8 0 0],'linewidth',3);
end
% plot vertical position
plot(timeIndex,vrs(:,2),'-','color',[0.2 0.2 0.8],'linewidth',1);
for i = 1:size(mrs,1)
    plot(timeIndex((mrs(i,1):mrs(i,2))), vrs(mrs(i,1):mrs(i,2),2),'-','color',[0 0 0.8],'linewidth',3);
end
ylim([-max(abs(vrs(:))),max(abs(vrs(:)))])

xlabel('time [sec]');
ylabel('velocity [deg/sec]');


%% plot fixation on image (use saccade parsing done in previous section)

close all
h2 = figure;
figure(h2);
cbac = [1.0 1.0 1.0, 0];
set(gcf,'color',cbac);

if ds2.trial(t).fake_image ==1
    imgpath = ['../img/fake/', char(ds2.trial(t).img_name)];
else
    imgpath = ['../img/real/', char(ds2.trial(t).img_name)];
end
C = imread(imgpath);

img_c = ds2.trial(t).imgRect ./ [scr.xres,scr.yres,scr.xres,scr.yres];
img_c = [img_c(1), img_c(2), img_c(3)-img_c(1), img_c(4)-img_c(2)];
ax_img = axes('pos',img_c);

%C = C(end : -1: 1, :, :);
image(ax_img , C)
axis off

ax_gaze = axes('pos',[0 0 1 1],'Color','none'); % left bottom width height
axes(ax_gaze);
hold on

display_x = [-(scr.xres/2)/ppd, (scr.xres/2)/ppd];
display_y = [-(scr.yres/2)/ppd, (scr.yres/2)/ppd];

plot(ax_gaze , xrs(:,1),xrs(:,2),'k-');
xlim(display_x);
ylim(display_y);

for i = 1:size(mrs,1)
    plot(xrs(mrs(i,1):mrs(i,2),1),xrs(mrs(i,1):mrs(i,2),2),'b-','linewidth',2);
end
if ~isempty(mrs)
    plot([xrs(mrs(:,1),1) xrs(mrs(:,2),1)]',[xrs(mrs(:,1),2) xrs(mrs(:,2),2)]','b.');
end

% make a table of fixations
n_fix = size(mrs,1) + 1;
fixtab = zeros(n_fix, 5);
for i = 1:n_fix
    
    fix_start = NaN;
    fix_end = NaN;
    fix_dur = NaN;
    fix_coord = NaN;
    
    if i==1
        fix_start = 1; %ds2.trial(t).timestamp(1);
    else
        fix_start = mrs(i-1,2)+1;
    end
    
    if i==n_fix
        fix_end = length(ds2.trial(t).timestamp); %(end);
    else
        fix_end = mrs(i,1)-1;
    end
    
    fix_dur = fix_end - fix_start;
    
    fix_coord = [nanmean(xrs(fix_start:fix_end,1)), nanmean(xrs(fix_start:fix_end,2))];
    
    fixtab(i,:) = [fix_start,fix_end,fix_dur,fix_coord];
end

for i = 1:n_fix
    plot(fixtab(i,4), fixtab(i,5),'o','color',[0 0 1],'markersize',fixtab(i,3)/25,'linewidth',1);
end

