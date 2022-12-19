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


%% define stimulus settings

dot_size = 100;


side_length = round(yRes/2);

% [x, y]
lower = round([xCenter, yCenter + side_length/(2*cosd(15))]);
upper_left = round([xCenter - side_length/2, lower(2)-side_length*cosd(15)]);
upper_right = round([xCenter + side_length/2, lower(2)-side_length*cosd(15)]);
xy = [lower', upper_left', upper_right'];

% transition probabilities [L, UL, UR]
probs = [0.5, 0.2, 0.7];

% decide starting point
ball_position = find(mnrnd(1,[1,1,1]/3));

move_clockwise = binornd(1, probs(ball_position), 1, 1);

next_ball_position = ball_position + sign(move_clockwise - 0.5);

if next_ball_position>3
    next_ball_position = 1;
elseif next_ball_position<1
    next_ball_position = 3;
end


%% creat animation
N_steps = 10;
N_animation_steps = 30;
% xy(:,start_point)

for t =1:N_steps
    
    Screen('DrawDots', window, xy, dot_size, black, [], 2);
    Screen('Flip', window);
    
    WaitSecs(rand(1)*(0.5-0.3) + 0.3);
    
    [x_path, y_path] = calculate_path(xy(:,ball_position), xy(:,next_ball_position), N_animation_steps);
    
    for i = 1:N_animation_steps
        Screen('DrawDots', window, xy, dot_size, black, [], 2);
        Screen('DrawDots', window, [x_path(i), y_path(i)], dot_size, white, [], 2);
        Screen('Flip', window);
    end

    % decide next
    ball_position = next_ball_position;
    move_clockwise = binornd(1, probs(ball_position), 1, 1);

    next_ball_position = ball_position + sign(move_clockwise - 0.5);

    if next_ball_position>3
        next_ball_position = 1;
    elseif next_ball_position<1
        next_ball_position = 3;
    end

end

sca;


