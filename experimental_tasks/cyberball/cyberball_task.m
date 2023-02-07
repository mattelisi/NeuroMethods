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
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0     0   640  480], 32, 2);


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

mouse_color = [255, 0, 0];
HideCursor;
dot_size = 100;
side_length = round(yRes/2);

% timing settings
min_isi = 0.5;
max_isi = 1;

% [x, y] coordinates of players
lower = round([xCenter, yCenter + side_length/(2*cosd(15))]);
upper_left = round([xCenter - side_length/2, lower(2)-side_length*cosd(15)]);
upper_right = round([xCenter + side_length/2, lower(2)-side_length*cosd(15)]);
xy = [lower', upper_left', upper_right'];

% transition probabilities [L, UL, UR]
probs = [0.5, 0.2, 0.7];

% decide starting point
ball_position = find(mnrnd(1,[1,1,1]/3));

% this code bits randomly select the next ball position
move_clockwise = binornd(1, probs(ball_position), 1, 1);
next_ball_position = ball_position + sign(move_clockwise - 0.5);
if next_ball_position>3
    next_ball_position = 1;
elseif next_ball_position<1
    next_ball_position = 3;
end

% task criteria
min_distance = dot_size;

%% creat animation
N_steps = 10;
N_animation_steps = 45;

% start with mouse at center 
SetMouse(xCenter, yCenter);
[xm,ym] = GetMouse;

for t =1:N_steps
    
    % draw playes and wait for ball passage
    Screen('DrawDots', window, xy, dot_size, black, [], 2);
    Screen('DrawDots', window, [xm,ym], dot_size, mouse_color);
    t_on = Screen('Flip', window);
    
    % wait for ball to be thrown whilst showing mouse cursor
    isi = rand(1)*(max_isi-min_isi) + min_isi; % here you can modify the timing
    while GetSecs<(t_on+isi)
        [xm,ym] = GetMouse;
        Screen('DrawDots', window, xy, dot_size, black, [], 2);
        Screen('DrawDots', window, [xm,ym], dot_size, mouse_color);
        Screen('Flip', window);
    end
    
    % calculate ball path
    [x_path, y_path] = calculate_path(xy(:,ball_position), xy(:,next_ball_position), N_animation_steps);
    
    intercept = 0;
    
    % now execute and display ball's passage
    for i = 1:N_animation_steps
        Screen('DrawDots', window, xy, dot_size, black, [], 2);
        Screen('DrawDots', window, [x_path(i), y_path(i)], dot_size, white, [], 2);
        
        [xm,ym] = GetMouse;
        Screen('DrawDots', window, [xm,ym], dot_size, mouse_color);
        
        distance = sqrt((xm-x_path(i))^2 + (ym-y_path(i))^2);
        if distance < min_distance
            intercept = 1;
            break;
        end
        
        Screen('Flip', window);
    end

    % decide next ball position 
    if intercept == 0 
        ball_position = next_ball_position;
        
    else
        % if succesfully intercepted, start from lower point (position=1)
        ball_position = 1; 
        
    end
    
    move_clockwise = binornd(1, probs(ball_position), 1, 1);

    next_ball_position = ball_position + sign(move_clockwise - 0.5);

    if next_ball_position>3
        next_ball_position = 1;
    elseif next_ball_position<1
        next_ball_position = 3;
    end

end

% close and end
ShowCursor;
sca;


