%% This short scriupt demonstrate how to create an attentional blink stimulus in matlab
% (currently only present a stream of letter/digits corresponding to 1 single trial)


% Clear the workspace
close all;
clear;
sca;

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0     0   640  480], 32, 2);


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


%% Settings for stimulus presentation
sequence_length = 25; % n letteres/digits
letters = 'AK'; % targets (2 letters)
digits = Randi(9,[sequence_length,1]); % sample random digits
lag = 3; % lag, in terms of presentation order, between first and second letter
position_T1 = Randi(5) + 5; % sample randomly presentation order of first letter (here is between 5 and 10)
duration = 0.15; % duration of presentation of each letter

% set NaN (not-a-number) values as placeholders in the list of digits, to signal when the letters should be presented
digits(position_T1) = NaN; 
digits(position_T1+lag) = NaN;

% set text size
Screen('TextSize', window, 60);

%% stimulus presentation loop
t_flip = Screen('Flip', window);

% set a counter for how many digits are presented
count_letter = 0;

% iterate over sequence length
for i=1:sequence_length

    if isnan(digits(i)) 
    	% present a letter if i-th value of 'digits' is NaN
        count_letter = count_letter+1;
        DrawFormattedText(window, letters(count_letter) ,'center','center');
    else
        DrawFormattedText(window, num2str(digits(i))  ,'center','center');
    end
    
    % update screen by presenting letter
    t_flip = Screen('Flip', window, t_flip+duration);

end

%% To do:
% add response collection (e.g. asking participants to type in the letter they saw)
% hint: you can use the 'input()' function


% close everything
sca;








