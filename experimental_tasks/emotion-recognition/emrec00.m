% Clear the workspace
close all;
clear;
sca;

%----------------------------------------------------------------------
%                         Settings
%----------------------------------------------------------------------
scr_width=1366;
scr_height=768;

%----------------------------------------------------------------------
%                       Collect information
%----------------------------------------------------------------------
subjectName=input('participant: ','s');
Gender_folder=input('enter gender of faces in Capital (F or M): ', 's');


%----------------------------------------------------------------------
%                       Task settings
%----------------------------------------------------------------------

img_format='.png';  %the format of your image files
bgd_col=255/2;  %background color - set to gray
fix_disp=0;     %position of fixation point on vertical axis. currently at center of screen
stimulus_ontime=10;  %max amount of time the stimulus is on screen. I'm setting this equal to the max response time, but could be set lower (in the mail we said 2 sec)
response_readtime=10; % max amount of time available to respond before next trial starts 
mask_ontime=1;  %amount of time the mask in on screen


%----------------------------------------------------------------------
%                       Stimuli
%----------------------------------------------------------------------

%load images and assign handles
number_images=21;
for img_i=1:number_images
    
    img_path=fullfile(cd,'img',Gender_folder,['Fig_',num2str(img_i),img_format]);
    img=imread(img_path);
    img_height=size(img,1);
    img_width=size(img,2);
    
    img_s(img_i) = Screen('openoffScreenwindow',-1,0,[0 0 img_width img_height]);
    Screen('PutImage',img_s(img_i),img,[0 0 img_width img_height]);
    
end

%----------------------------------------------------------------------
%                       Initialize PTB
%----------------------------------------------------------------------

% Setup PTB with some default values
PsychDefaultSetup(2);

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);

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

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');



%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

% Animation loop: we loop for the total number of trials
for trial = 1:numTrials

   
end

% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;
