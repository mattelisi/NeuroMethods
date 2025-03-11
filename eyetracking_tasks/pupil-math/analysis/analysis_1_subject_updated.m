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
raw_data = '../data/S52.edf';

% system('edf2asc ../data/S1.edf -s -miss -1.0')

% load eye movement file
ds = edfmex(raw_data); % ,'-miss -1.0'
save('S52_edfstruct.mat', 'ds');

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
        
        % remove gaze points outside screen
        eye_x(eye_x<0 | eye_x>scr.xres | eye_y<0 | eye_y>scr.yres ) = NaN;
        eye_y(eye_y<0 | eye_y>scr.yres | eye_x<0 | eye_x>scr.xres ) = NaN;
        pupil_size(eye_y<0 | eye_y>scr.yres | eye_x<0 | eye_x>scr.xres ) = NaN;
        pupil_size(pupil_size==0) = NaN;
        
        % save ecverything into a single structure
        ds2.trial(trial_count).trial_n = trial_n;
        ds2.trial(trial_count).t_start = t_start;
        ds2.trial(trial_count).t_end = t_end;
        ds2.trial(trial_count).t_fix = t_fix;
        
        ds2.trial(trial_count).t_N1 = t_N1;
        ds2.trial(trial_count).t_N2 = t_N2;
        ds2.trial(trial_count).t_resp = t_resp;
        ds2.trial(trial_count).N1 = N1;
        ds2.trial(trial_count).N2 = N2;
        
        % remove double presentation of trials
        if trial_count > 1
            % previous N1 and N2 values
            previousN1 = [ds2.trial(1:trial_count-1).N1];
            previousN2 = [ds2.trial(1:trial_count-1).N2];
            
            % check if the current (N1, N2) pair is already present
            if any((previousN1 == N1) & (previousN2 == N2))
                % If yes, remove the current trial and continue to the next iteration
                ds2.trial(trial_count) = [];
                trial_count = trial_count-1;
                continue
            end
        end
        
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
    %pa(pa<400) = NaN;
    
    % the criterion above leave some isolate non-nan datapoints
    % we filter them using a duration criterion:
    durationThreshold = 50;
    isValid = ~isnan(pa);

    % start and end indices of each contiguous run of valid samples.
    startIdx = find(diff([0, isValid]) == 1);
    endIdx   = find(diff([isValid, 0]) == -1);
    
    % loop over each contiguous run of valid (non-NaN) samples
    for iRun = 1:numel(startIdx)
        s = startIdx(iRun);
        e = endIdx(iRun);
        duration = double(time(e)) - double(time(s));
        % If the duration of this run is shorter than our threshold, remove it
        if duration < durationThreshold
            pa(s:e) = NaN;
        end
    end
    
    % linearly interpolate missing data
    validIdx = ~isnan(pa);
    pa = interp1(single(time(validIdx)), pa(validIdx), single(time), 'linear');
    
    % compute average pupil dilation for baseline (before first number, 
    % corresponding to negative time stamps)
    % use 300 ms before N1
    baseline_index = find(time>-300 & time<=0);
    baseline = nanmean(pa(baseline_index));
    
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

%% plot by difficulty

% Indices of hard vs. easy trials
hard_idx = ([ds2.trial.is_hard] == 1);
easy_idx = ([ds2.trial.is_hard] == 0);

% Figure out the maximum timestamp length across all trials 
% (so we can define matrix widths)
all_tmax = arrayfun(@(x) max(x.timestamp), ds2.trial);
max_length = max(all_tmax); 

% Pre-allocate pupil matrices for hard and easy
pa_matrix_hard = NaN(sum(hard_idx), max_length);
pa_matrix_easy = NaN(sum(easy_idx), max_length);

% Counters to track row indices in the matrices
iH = 0;  
iE = 0;

% loop
for i = 1:length(ds2.trial)
    
    time = ds2.trial(i).timestamp;
    pa   = ds2.trial(i).pupil_size;
    t_0  = ds2.trial(i).t_N1;
    t_1  = ds2.trial(i).t_resp;
    
    % velocity threshold
    pavel = vecvel(pa', 1000, 2);  
    pa(abs(pavel) > 0.4*10^4) = NaN;
    
    % remove isolated points below 50ms duration threshold
    durationThreshold = 50;   % 50 ms
    isValid = ~isnan(pa);
    startIdx = find(diff([0, isValid]) == 1);
    endIdx   = find(diff([isValid, 0]) == -1);
    for iRun = 1:numel(startIdx)
        s = startIdx(iRun);
        e = endIdx(iRun);
        duration = double(time(e)) - double(time(s));
        if duration < durationThreshold
            pa(s:e) = NaN;
        end
    end
    
    % linear interpolation
    validIdx = ~isnan(pa);
    pa = interp1(single(time(validIdx)), pa(validIdx), single(time), 'linear');
    
    % baseline: 300 ms before N1 (time<0)
    baseline_index = find(time>-300 & time<=0);
    baseline = nanmean(pa(baseline_index));
    
    % select data
    pa_ok = pa(time>=0 & time<(t_1 - t_0));
    
    % normalise-
    pa_ok = ((pa_ok / baseline) - 1)*100;
    
    % palce in easy or hard matrix
    if ds2.trial(i).is_hard == 1
        iH = iH + 1;
        pa_matrix_hard(iH, 1:numel(pa_ok)) = pa_ok;
    else
        iE = iE + 1;
        pa_matrix_easy(iE, 1:numel(pa_ok)) = pa_ok;
    end
    
end

% remove colums with all-NaN if present

% hard matrix
allNaNColsHard = all(isnan(pa_matrix_hard), 1);
pa_matrix_hard(:, allNaNColsHard) = [];

% easy matrix
allNaNColsEasy = all(isnan(pa_matrix_easy), 1);
pa_matrix_easy(:, allNaNColsEasy) = [];

% timestamp vector
time_sec_hard = (1 : size(pa_matrix_hard, 2)) / 1000; 
time_sec_easy = (1 : size(pa_matrix_easy, 2)) / 1000;


% Compute means and SEMs for each condition

% Hard trials
pa_mean_hard   = nanmean(pa_matrix_hard);            % across rows
pa_std_hard    = nanstd(pa_matrix_hard);             % across rows
n_hard         = sum(~isnan(pa_matrix_hard));        % valid samples in each column
sem_hard       = pa_std_hard ./ sqrt(n_hard);        % SEM
pa_mean_hard_smooth = movmean(pa_mean_hard, 300);    % smoothing

% Easy trials
pa_mean_easy   = nanmean(pa_matrix_easy);
pa_std_easy    = nanstd(pa_matrix_easy);
n_easy         = sum(~isnan(pa_matrix_easy));
sem_easy       = pa_std_easy ./ sqrt(n_easy);
pa_mean_easy_smooth = movmean(pa_mean_easy, 300);

% time vector
time_sec = (1:length(pa_mean_hard_smooth)) / 1000;

% figure
figure('Color','w'); 
hold on

% A reference line at x=2 s, for example:
line([2,2],[-40,85],'LineWidth',0.2,'LineStyle','--','Color',[0.5 0.5 0.5]);

% -- Hard fill (SEM ribbon) --
fill([time_sec_hard, fliplr(time_sec_hard)], ...
     [pa_mean_hard_smooth+sem_hard, fliplr(pa_mean_hard_smooth-sem_hard)], ...
     'r', 'FaceAlpha', 0.2, 'LineStyle','none');

% -- Hard mean line --
pHard = plot(time_sec_hard, pa_mean_hard_smooth, 'r', 'LineWidth', 2, ...
    'DisplayName','Hard');

% -- Easy fill (SEM ribbon) --
fill([time_sec_easy, fliplr(time_sec_easy)], ...
     [pa_mean_easy_smooth+sem_easy, fliplr(pa_mean_easy_smooth-sem_easy)], ...
     'b', 'FaceAlpha', 0.2, 'LineStyle','none');

% -- Easy mean line --
pEasy = plot(time_sec_easy, pa_mean_easy_smooth, 'b', 'LineWidth', 2, ...
    'DisplayName','Easy');

% Styling
ylim([-20, 40])
xlim([-0.5, 10])
xlabel('Time [sec]');
ylabel('Pupil area [% change from baseline]');

% Legend (only lines, ignoring the ribbons)
legend([pHard, pEasy], {'Hard','Easy'}, 'Location','best');

hold off
