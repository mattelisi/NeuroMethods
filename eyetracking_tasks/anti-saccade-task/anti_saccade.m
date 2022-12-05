function [] = anti_saccade(n_trials)
%---------------------------------------------------------------------------------------
%
% Anti saccade task
% Matteo Lisi, 2022, matteo@inventati.org
%
%----------------------------------------------------------------------------------------
% Screen setup info: change these accordingto the monitor and viewing distance used
scr.subDist = 80;   % subject distance (cm)
scr.width   = 570;  % monitor width (mm)


%----------------------------------------------------------------------------------------
if nargin < 1
    n_trials = 30;
end

%----------------------------------------------------------------------------------------
% focus on the command window
commandwindow;
home;

addpath('./functions');

% Setup PTB with some default values
% PsychDefaultSetup(2);

% Seed the random number generator.
rng('shuffle')

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

%----------------------------------------------------------------------------------------
%% collect some info?
SJ = getSJinfo;
if SJ.number > 0
    info_str = sprintf('S%i\t', SJ.number);
    filename = sprintf('S%i', SJ.number);
end

% create data fid
datFid = fopen(filename, 'w');

%----------------------------------------------------------------------
%% Screen setup

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% get rid of PsychtoolBox Welcome screen
%Screen('Preference', 'VisualDebugLevel',3);

% Define black, white and grey
scr.white = WhiteIndex(screenNumber);
scr.black = BlackIndex(screenNumber);
scr.grey = round(scr.white/2);
scr.lightgrey = scr.grey + 5;

% Open the screen
%[scr.main, scr.rect] = PsychImaging('OpenWindow', screenNumber, scr.grey);
%[scr.main, scr.rect] = PsychImaging('OpenWindow', screenNumber, scr.grey, [0 0 1920 1080]/2, 32, 2);
%imagingMode = kPsychNeed32BPCFloat;
%[scr.main, scr.rect] = Screen('OpenWindow',screenNumber, [0.5 0.5 0.5],[],32,2,0,2,imagingMode);
[scr.main, scr.rect] = Screen('OpenWindow',screenNumber, scr.grey);

% Flip to cleartext_size
Screen('FillRect',scr.main, scr.grey);
Screen('Flip', scr.main);

% Query the frame duration
scr.fd = Screen('GetFlipInterval', scr.main);

% Query the maximum priority level
MaxPriority(scr.main);

% Get the centre coordinate of the window
[scr.xCenter, scr.yCenter] = RectCenter(scr.rect);
[scr.xres, scr.yres] = Screen('WindowSize', scr.main); % heigth and width of screen [pix]

% Set the blend funciton for the screen
Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

ppd = va2pix(1,scr);   % pixel per degree conversion factor

text_size = round((ppd/56) * 21); % text size


% -------------------------------------------------------------------
%% init eyelink stuff

const.TEST = 0; % dummy eyelink mode
visual.bgColor = [scr.grey,scr.grey,scr.grey];	% background color when calibrating
visual.fgColor = scr.black; % foreground color when calibrating
visual.ppd = ppd;

% initialize eyelink-connection
[el, err]=initEyelink(filename,visual,const,scr);
if err==el.TERMINATE_KEY
    return
end

% determine recorded eye
if ~isfield(const,'recEye') && ~const.TEST
    %evt = Eyelink('newestfloatsample');
    %const.recEye = find(evt.gx ~= -32768);
    eye_used = Eyelink('EyeAvailable'); % get tracked eye 
    const.recEye = Eyelink('EyeAvailable');
end

% tracker calibration
if ~const.TEST
    calibresult = EyelinkDoTrackerSetup(el);
    if calibresult==el.TERMINATE_KEY
        return
    end
end

%----------------------------------------------------------------------
%% visual settings

tar_ecc = ppd*8;
fix_location = [scr.xCenter, scr.yCenter];
tarX_locations = round([scr.xCenter - tar_ecc, scr.xCenter + tar_ecc]);
tar_locations = [tarX_locations; scr.yCenter, scr.yCenter];
tar_size = round(1.5*ppd);

fixCkRad = round(2*ppd);

%% Time settings
tFix = 0.2;
soa_range = [0.2, 0.4];
maxRT = 5;

% ------------------------------------------------------------------
%% misc
% Make a directory for the results
resultsDir = [pwd '/data/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end

%----------------------------------------------------------------------
%% run experiment

% wait for a key press to start
instructions = 'Press any key to begin';
Screen('TextSize', scr.main, text_size);
Screen('TextFont', scr.main, 'Arial');
DrawFormattedText(scr.main, instructions, scr.xCenter - ceil(scr.xCenter/1.2), 'center', scr.white);
Screen('Flip', scr.main);
SitNWait;


for t = 1:n_trials

    % This supplies a title at the bottom of the eyetracker display
    Eyelink('command', 'record_status_message '' Trial %d of %d''', t, n_trials - t);

    % this marks the start of the trial
    Eyelink('message', 'TRIALID %d', t);

    ncheck = 0;
    fix    = 0;
    record = 0;
    if const.TEST < 2
        while fix~=1 || ~record
            if ~record
                Eyelink('startrecording');	% start recording
                % You should always start recording 50-100 msec before required
                % otherwise you may lose a few msec of data
                WaitSecs(.1);
                if ~const.TEST
                    key=1;
                    while key~= 0
                        key = EyelinkGetKey(el);		% dump any pending local keys
                    end
                end

                err=Eyelink('checkrecording'); 	% check recording status
                if err==0
                    record = 1;
                    Eyelink('message', 'RECORD_START');
                else
                    record = 0;	% results in repetition of fixation check
                    Eyelink('message', 'RECORD_FAILURE');
                end
            end

            if fix~=1 && record

                Eyelink('command','clear_screen 0');
                Screen('FillRect',scr.main, scr.grey);
                Screen('Flip', scr.main);
                WaitSecs(0.1);

                % CHECK FIXATION
                fix = checkFix(scr, fixCkRad, const, fix_location, ppd);
                ncheck = ncheck + 1;
            end

            if fix~=1 && record
                % calibration, if maxCheck drift corrections did not succeed
                if ~const.TEST
                    calibresult = EyelinkDoTrackerSetup(el);
                    if calibresult==el.TERMINATE_KEY
                        return
                    end
                end
                record = 0;
            end
        end
    else
        Screen('DrawDots', scr.main, fix_location , round(ppd*0.2), scr.white,[], 4); % fixation
        Screen('Flip', scr.main);
        WaitSecs(0.2);
    end

    Eyelink('message', 'TRIAL_START %d', t);
    Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW

    % draw trial information on EyeLink operator screen
    Eyelink('command','draw_cross %d %d', scr.xCenter, scr.yCenter);

    % predefine time stamps
    tOn    = NaN;
    tSac   = NaN; 

    % random
    soa = rand(1)* (soa_range(2)-soa_range(1)) + soa_range(1);
    target_side = (randn(1)>0) + 1;
    anti_saccade = randn(1)>0;

    if target_side==2
        if anti_saccade 
            tar_colors = [scr.lightgrey , 255;scr.lightgrey , 0; scr.lightgrey  ,0];
        else
            tar_colors = [scr.lightgrey , 0;scr.lightgrey , 170; scr.lightgrey  ,0];
        end
    else
        if anti_saccade 
            tar_colors = [255, scr.lightgrey; 0, scr.lightgrey; 0 ,scr.lightgrey];
        else
            tar_colors = [255, scr.lightgrey; 0, scr.lightgrey; 0 ,scr.lightgrey];
        end
    end

    % other flags
    ex_fg = 0;      % 0 = ok; 1 = fix break; 2 = tooSlow

    % draw fixation & placeholders
    Screen('DrawDots', scr.main, fix_location , round(ppd*0.2), scr.black,[], 4); % fixation
    Screen('DrawDots', scr.main, tar_locations , tar_size, scr.lightgrey ,[], 2); % placeholders
    tFix = Screen('Flip', scr.main,0);
    Eyelink('message', 'EVENT_FixationDot');

    % fixation check
    while GetSecs < (tFix + soa - scr.fd)
        [x,y] = getCoord(scr, const); % get eye position data
        chkres = checkGazeAtPoint([x,y],[scr.xCenter, scr.yCenter],fixCkRad);
        if ~chkres
            ex_fg = 1;
        end
    end
    
    % draw stimuli 
    Screen('DrawDots', scr.main, fix_location , round(ppd*0.2), scr.black,[], 4); % fixation
    Screen('DrawDots', scr.main, tar_locations , tar_size, tar_colors ,[], 2); % placeholders
    tOn = Screen('Flip', scr.main);
    Eyelink('message', 'EVENT_TargetOnset');

    % loop gaze control for response period
    while GetSecs < (tOn + maxRT)

        if isnan(tSac)
            [x,y] = getCoord(scr, const); % get eye position data
            chkres = checkGazeAtPoint([x,y],[scr.xCenter, scr.yCenter],fixCkRad);
            % fprintf('%.2f\t%.2f\n',x,y);
            if chkres==0
                tSac = GetSecs;
                Eyelink('message', 'EVENT_Saccade1Started');
                break;
            end
        end
        
    end
    
    
    correct = 0;
    
    Screen('DrawDots', scr.main, tar_locations , tar_size, tar_colors ,[], 2); % placeholders
    Screen('Flip', scr.main);

    if isnan(tSac)
        ex_fg = 2;
    else

        while  GetSecs < (tSac + 0.05)
            
            [x,y] = getCoord(scr, const); % get eye position data

            if ~anti_saccade 
                chksac = checkGazeAtPoint([x,y],  tar_locations(:,target_side)', tar_ecc - 3*ppd);
            else
                chksac = checkGazeAtPoint([x,y],  tar_locations(:,3-target_side)', tar_ecc - 3*ppd);
            end

            if chksac
                correct = 1;
                break;
            end
        end
    end

    if correct ==0
        beep;
    end

    %% trial end

    switch ex_fg

        case 1
            data = 'fixBreak';
            Eyelink('command','draw_text 100 100 15 Fixation break');

        case 2
            data = 'tooSlow';
            Eyelink('command','draw_text 100 100 15 Too slow or no saccade');

        case 0

            % collect trial information
            trialData = sprintf('%.2f\t%.2f\t%.2f\t',[soa target_side anti_saccade correct]);

            % timing
            timeData = sprintf('%.2f\t%.2f\t%.2f',[tFix tOn tSac]);

            % other response data
            rt = sprintf('%.2f',tSac - tOn);

            % collect data for tab [14 x trialData, 6 x timeData, 1 x respData]
            data = sprintf('%s\t%s\t%s\t%s',trialData, timeData, rt);

    end

    Eyelink('message', 'TRIAL_END %d',  t);
    Eyelink('stoprecording');

    dataStr = sprintf('%i\t%s\n',t,data); % print data to string
    %if const.TEST; fprintf(1,sprintf('\n%s',dataStr));end

    % save trial info to eye mv rec
    Eyelink('message','TrialData %s', dataStr);

    
    % go to next trial if fixation was not broken
    if strcmp(data,'fixBreak')
        trialDone = 0;
        feedback('Please maintain fixation until target appears.',tar_locations(1),tar_locations(2),scr,visual);
    elseif strcmp(data,'tooSlow')
        trialDone = 0;
        feedback('Too slow.',tar_locations(1),tar_locations(2),scr,visual);
    else
        trialDone = 1;
        Eyelink('message', 'TrialData %s', dataStr);% write data to edfFile
        fprintf(datFid,dataStr);                    % write data to datFile
    end

    % isi
    WaitSecs(0.5);

end

%----------------------------------------------------------------------
%% close data file
fclose(datFid); % close datFile

%----------------------------------------------------------------------
%% final feedback and end screen
Screen('TextSize', scr.main, text_size);
Screen('TextFont', scr.main, 'Arial');

DrawFormattedText(scr.main, 'The end! Thanks for participanting.\n\n\n(press any key to exit)', scr.xCenter - ceil(scr.xCenter/1.2), scr.yCenter, scr.white);
Screen('Flip', scr.main);
SitNWait;

% wrap up eyething stuff and receive data file
reddUp;

%----------------------------------------------------------------------
%% Close the onscreen window
Screen('CloseAll');
