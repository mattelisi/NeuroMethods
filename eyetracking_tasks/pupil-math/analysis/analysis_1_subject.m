% analysis pupil size pupil-math task
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

%
maxRT = 8;

%% import file
% location of raw data file
raw_data = '../data/S2301.edf';

% system('edf2asc ../data/S1.edf -s -miss -1.0')

% load eye movement file
ds = edfmex(raw_data); % ,'-miss -1.0'
save('S2301_edfstruct.mat', 'ds');

% see the content of the data
ds.FSAMPLE
ds.FEVENT.message

% how many trials? here are the index of img onsets for each trial
find(strcmp({ds.FEVENT.message}, 'EVENT_FixationDot')==1)

%% prepare data

% which eye was tracked?
% 0=left 1=right (add 1 for indexing below)
eye_tracked = 1 + mode([ds.FEVENT.eye]);

% initialize 
trial_n = NaN;
trial_n_2 = NaN;
trial_n_3 = NaN;
t_start = NaN;
t_end =  NaN;
t_fix =  NaN;
t_N1 =  NaN;
t_N2 =  NaN;
t_resp =  NaN;
is_hard = NaN;
response =  NaN;
N1 =  NaN;
N2 =  NaN;
accuracy =  NaN;
timestamp  =  [];
eye_x =  [];
eye_y =  [];
pupil_size = [];

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
        
        % fix onset
        if strcmp(sa(1),'EVENT_FixationDot')
           t_fix = int32(ds.FEVENT(i).sttime);
        end
        
        % first number
        if strcmp(sa(1),'EVENT_N1')
           t_N1 = int32(ds.FEVENT(i).sttime);
        end
        
        % second number
        if strcmp(sa(1),'EVENT_N2')
           t_N2 = int32(ds.FEVENT(i).sttime);
           t_resp = t_N2 + 8 * 1000;
        end
        
        % end of eye movement recoding
        if strcmp(sa(1),'TRIAL_END')
           trial_n_2 = str2double(sa(2));
           t_end = ds.FEVENT(i).sttime;
        end
        
        % data info
        if strcmp(sa(1),'TrialData')
           trial_n_3 = str2double(sa(2));
           is_hard = str2double(sa(4));
           N1 =  str2double(sa(5));
           N2 =  str2double(sa(6));
           response =  str2double(sa(7));
           accuracy =  str2double(sa(8));
        end
    end
    
    % if we have everything, then extract gaze position samples
    if ~isnan(trial_n) && ~isnan(trial_n_2) && ~isnan(trial_n_3)
        
        trial_count = trial_count+1;
        
        % find onset-offset of relevant recording
        index_start = find(ds.FSAMPLE.time==t_start);
        index_end = find(ds.FSAMPLE.time==t_resp);
        
        % timestamp (set 0 for img onset)
        timestamp  =  int32(ds.FSAMPLE.time(index_start:index_end)) - t_N1;
        
        eye_x =  ds.FSAMPLE.gx(eye_tracked, index_start:index_end);
        eye_y =  ds.FSAMPLE.gy(eye_tracked, index_start:index_end);
        pupil_size = ds.FSAMPLE.pa(eye_tracked, index_start:index_end);
        
        % remove missing
        eye_x(eye_x==100000000 | eye_y==100000000) = NaN;
        eye_y(eye_y==100000000 | eye_x==100000000) = NaN;
        pupil_size(eye_y==100000000 | eye_x==100000000) = NaN;
        
        % remove gaze points outside screen etc
        eye_x(eye_x<0 | eye_x>scr.xres | eye_y<0 | eye_y>scr.yres ) = NaN;
        eye_y(eye_y<0 | eye_y>scr.yres | eye_x<0 | eye_x>scr.xres ) = NaN;
        pupil_size(eye_y<0 | eye_y>scr.yres | eye_x<0 | eye_x>scr.xres ) = NaN;
        
        pupil_size(pupil_size==0) = NaN;
        
        % save everything into a single structure
        ds2.trial(trial_count).trial_n = trial_n;
        ds2.trial(trial_count).t_start = t_start;
        ds2.trial(trial_count).t_end = t_end;
        ds2.trial(trial_count).t_fix = t_fix;
        
        ds2.trial(trial_count).t_N1 = t_N1;
        ds2.trial(trial_count).t_N2 = t_N2;
        ds2.trial(trial_count).t_resp = t_resp;
        ds2.trial(trial_count).N1 = N1;
        ds2.trial(trial_count).N2 = N2;
        ds2.trial(trial_count).response = response;
        ds2.trial(trial_count).accuracy = accuracy;
        ds2.trial(trial_count).is_hard = is_hard;
        
        ds2.trial(trial_count).timestamp  =  timestamp  ;
        ds2.trial(trial_count).eye_x =  eye_x;
        ds2.trial(trial_count).eye_y =  eye_y;
        ds2.trial(trial_count).pupil_size =  pupil_size;
        
        % re-initialize
        trial_n = NaN;
        trial_n_2 = NaN;
        trial_n_3 = NaN;
        t_start = NaN;
        t_end =  NaN;
        t_fix =  NaN;
        t_N1 =  NaN;
        t_N2 =  NaN;
        t_resp =  NaN;
        is_hard = NaN;
        response =  NaN;
        N1 =  NaN;
        N2 =  NaN;
        accuracy =  NaN;
        timestamp  =  [];
        eye_x =  [];
        eye_y =  [];
        pupil_size = [];

        
    end
    
end
    
%% plot raw data 
plot(ds2.trial(1).timestamp, ds2.trial(1).pupil_size)
hold on
plot(ds2.trial(2).timestamp, ds2.trial(2).pupil_size)
plot(ds2.trial(3).timestamp, ds2.trial(3).pupil_size)
plot(ds2.trial(4).timestamp, ds2.trial(4).pupil_size)
ylim([400 , 1800])
hold off

%% normalize and average analysis

% create a matrix where to align data from all trials
pa_matrix = NaN(length(ds2.trial), max([ds2.trial(1:4).timestamp]));

for i = 1:length(ds2.trial)

    time = ds2.trial(i).timestamp;
    pa = ds2.trial(i).pupil_size;
    t_0 = ds2.trial(i).t_N1;
    t_1 = ds2.trial(i).t_resp;
    
    % compute rate of change in pupil size
    pavel = vecvel(pa', 1000, 2);  
    
    %     Make a plot of rate of change for a single trial
    %     plot(time, abs(pavel)); hold on
    %     plot([-4000, 12000],[0.4,0.4]*10^4); hold off
    
    % by eyeballing the plots above, I choose 0.4*10^4 as a threshold, and
    % I change to Nan all values that exceed it
    pa(abs(pavel) > 0.4*10^4) = NaN;
    pa(pa<650) = NaN;
    
    % compute average pupil dilation for baseline (before first number, 
    % corresponding to negative time stamps)
    baseline = nanmean(pa(time<0));
    
    % select only the same interval for each trial, starting with
    % presentation of first number
    pa_ok = pa(time>=0 & time<(t_1 - t_0));
    
    % normalize by computing proportion change with respect to baseline
    pa_ok = ((pa_ok / baseline)-1).*100;
    
    % save current trials in the matrix
    pa_matrix(i, 1:size(pa_ok,2)) = pa_ok ;
    
end

% compute the averave
pa_mean = nanmean(pa_matrix);

% transform time in seconds
time_sec = (1:length(pa_mean))/1000;

% make plot
set(gcf,'color','w');
hold on
line(time_sec, pa_matrix,'LineWidth',0.2,'LineStyle','-','color',[0.8 0.8 0.8])
line([2,2],[-40,85],'LineWidth',0.2,'LineStyle','--','color',[0.5 0.5 0.5]);
plot(time_sec, pa_mean,'k','LineWidth',2,'LineStyle','-')
hold off
ylim([min(pa_matrix(:)), max(pa_matrix(:))])
xlim([-0.5, 10])
xlabel('Time [sec]');
ylabel('Pupil area [% change from baseline]');


%% alternative plot with standard error:

% Calculating the standard error of the mean (SEM)
pa_std = nanstd(pa_matrix); % Standard deviation of pa_matrix, ignoring NaNs
n = sum(~isnan(pa_matrix)); % Count non-NaN entries for each time point
sem = pa_std ./ sqrt(n); % SEM calculation

% Mean and SEM calculations for plotting
pa_mean = nanmean(pa_matrix); % Mean of pa_matrix, ignoring NaNs
pa_mean_smooth = movmean(pa_mean,300); % Moving average of pa_mean for smoothing

% Time vector for plotting
time_sec = (1:length(pa_mean_smooth))/1000;

% Plotting
set(gcf,'color','w');
hold on

%line(time_sec, pa_matrix,'LineWidth',0.2,'LineStyle','-','color',[0.8 0.8 0.8])
line([2,2],[-40,85],'LineWidth',0.2,'LineStyle','--','color',[0.5 0.5 0.5]);

% Adding the ribbon for SEM
fill([time_sec, fliplr(time_sec)], [pa_mean_smooth+sem, fliplr(pa_mean_smooth-sem)], ...
    [0.9 0.9 0.9], 'linestyle', 'none');

% Re-plotting the mean line so it's on top of the ribbon
plot(time_sec, pa_mean_smooth, 'k', 'LineWidth', 2);

ylim([-20, 40])
xlim([-0.5, 10])
xlabel('Time [sec]');
ylabel('Pupil area [% change from baseline]');

hold off

