% Clear the workspace
close all;
clear;
sca;

% add custom functions 
addpath('./functions');

%----------------------------------------------------------------------
%                       Collect information
%----------------------------------------------------------------------
subjectName=input('participant: ','s');
Gender_folder=upper(input('enter gender of faces (F or M): ', 's'));

if ~ (strcmp(Gender_folder,'M') || strcmp(Gender_folder,'F'))
    error('unknown string for face gender (should be either M or F)');
end

%----------------------------------------------------------------------
%                       Task settings
%----------------------------------------------------------------------

stim_dur = 10;  % max amount of time the stimulus is on screen (seconds)
mask_dur = 1;   % amount of time the mask in on screen
repetitions = 2; % how many repetitions per image
iti = 1; % inter trial interval

%----------------------------------------------------------------------
%                       Initialize PTB
%----------------------------------------------------------------------

% Setup PTB with some default values
PsychDefaultSetup(2);

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 1800 1600], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Get the heigth and width of screen [pix]
[xRes, yRes] = Screen('WindowSize', window); 

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%----------------------------------------------------------------------
%                       Stimuli
%----------------------------------------------------------------------

% generate a pseudorandom trial list
number_images=21; % number of morhped images
trial_matrix = combvec(1:repetitions, 1:number_images)';
trial_matrix = trial_matrix(randperm(size(trial_matrix,1)),:);
n_trials = number_images*repetitions;

% fixation
fix_size = 30;

% image width 
image_width = 500;

% define coordinates of wherer to present image
% images are 355 x 464 pixels
img_rect = CenterRectOnPoint([0,0, image_width, round(464/355 * image_width) ], xCenter, yCenter);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
happyKey = KbName('H');
sadKey = KbName('S');


%----------------------------------------------------------------------
%                 Prepare for saving data
%----------------------------------------------------------------------

% Make a directory for the results
resultsDir = [pwd '/data/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end

% prep data header
datFid = fopen([resultsDir subjectName], 'w');
fprintf(datFid, 'id_n\tgender\timg_name\tmorph_level\tresp_happy\tRT\n');

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

DrawFormattedText(window, 'Welcome to our experiment \n\n Please indicate by pressing H or S if the faces you see are happy or sad, respectively \n\n Press Any Key To Start',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;

HideCursor; % hide mouse cursor

% Animation loop: we loop for the total number of trials
for t = 1:n_trials
    
    % fixation spot
    Screen('FillOval', window, black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], xCenter, yCenter));
    Screen('Flip', window);
    WaitSecs(iti/2);
    
    % load image
    img_path = [pwd '/img/' upper(Gender_folder) '/Fig_' num2str(trial_matrix(t,2)) '.png'];
    img = imread(img_path);
    face_tex = Screen('MakeTexture', window, img);
    
    % generate noise texture
    scrambled_img = imscramble(img,0.9, 'cutoff');
    noise_tex = Screen('MakeTexture', window, scrambled_img);
    
    % put stimulus on screen
    Screen('DrawTexture', window, face_tex, [], img_rect);
    [~,t0] = Screen('Flip', window);
    
    % wait for response or until time run out
    resp_happy = NaN;
    while (GetSecs-t0) <= stim_dur
        [keyisdown, secs, keycode] = KbCheck(-1);
        if keyisdown && (keycode(happyKey) || keycode(sadKey))
            tResp = secs - t0;
            if keycode(happyKey)
                resp_happy = 1;
            else
                resp_happy = 0;
            end
            break;
        end
    end
    
    % present mask
    Screen('DrawTexture', window, noise_tex, [], img_rect);
    [~,tmask] = Screen('Flip', window);
    % WaitSecs(mask_dur);
    
    % write data line to file
    dataline = sprintf('%s\t%s\t%s\t%i\t%i\t%2f\n', subjectName, Gender_folder, ['Fig_' num2str(trial_matrix(t,2)) '.png'], trial_matrix(t,2), resp_happy, tResp);
    fprintf(datFid, dataline);
    
    % back to fixation spot
    Screen('FillOval', window, black, CenterRectOnPoint([0,0, round(fix_size), round(fix_size)], xCenter, yCenter));
    Screen('Flip', window, tmask + mask_dur);
    WaitSecs(iti/2);

end

% close data file
fclose(datFid);

% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;
