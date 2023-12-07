function [] = ilt2
%---------------------------------------------------------------------------------------
%
% Instrumental learning task with Hiragana characters and super-mario coins
% Updated to child-friendly version: squares and discs, fixed colors for 
% reward and losses (red and blue respectively); set number to -1 for
% practice.
%
% Matteo Lisi, 2019, matteo@inventati.org
%
% Version 2: "dungeon" task
%
%----------------------------------------------------------------------------------------
% Screen setup info: change these accordingto the monitor and viewing distance used
scr.subDist = 90;   % subject distance (cm)
scr.width   = 300;  % monitor width (mm)

%----------------------------------------------------------------------------------------
isiTimeSecs = 0.3; % intertrial interval in secs

%----------------------------------------------------------------------------------------
% save images for paper
save_images = 0;
im_counter = 0;

% if save_images
%     imageArray = Screen('GetImage', scr.main);
%     imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
%     im_counter = im_counter +1;
% end

%----------------------------------------------------------------------------------------
% focus on the command window
commandwindow;
home;

addpath('functions');

% Setup PTB with some default values
PsychDefaultSetup(2);

% Seed the random number generator.
rng('shuffle')

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

%----------------------------------------------------------------------------------------
%% collect some info?
SJ = getSJinfo;
if SJ.number > 0
    info_str = sprintf('%i\t%s\t%.2f\t%s\t', SJ.number, SJ.id, SJ.age, SJ.gend);
    filename = sprintf('%i%s.txt', SJ.number, SJ.id);
end

reply = input('\n Skip intro? y/n [n]:','s');
if isempty(reply)
    reply = 'n';
end

%----------------------------------------------------------------------
%% Screen setup

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = min(Screen('Screens'));

% Define black, white and grey
scr.white = WhiteIndex(screenNumber);
scr.black = BlackIndex(screenNumber);

% Open the screen
[scr.main, scr.rect] = PsychImaging('OpenWindow', screenNumber, scr.black, [], 32, 2);
%[scr.main, scr.rect] = PsychImaging('OpenWindow', screenNumber, scr.black, [0 0 800 600], 32, 2);

% Flip to cleartext_size
Screen('Flip', scr.main);

% Query the frame duration
scr.fd = Screen('GetFlipInterval', scr.main);

% Set the text size
Screen('TextSize',scr.main, 60);

% Query the maximum priority level
MaxPriority(scr.main);

% Get the centre coordinate of the window
[scr.xCenter, scr.yCenter] = RectCenter(scr.rect);
[scr.xres, scr.yres] = Screen('WindowSize', scr.main); % heigth and width of screen [pix]

% Set the blend funciton for the screen
Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

ppd = va2pix(1,scr);   % pixel per degree conversion factor

text_size = round((ppd/56) * 21); % text size

%----------------------------------------------------------------------
%% symbol locations
image_size = round(3*ppd);
door_size = round(6*ppd);

x_centers = scr.xCenter + round([-5, 5] * ppd);
rect_img = zeros(2,4);
rect_img(1,:)= CenterRectOnPoint([0,0, image_size, image_size], x_centers(1), scr.yCenter-round(door_size*0.65));
rect_img(2,:)= CenterRectOnPoint([0,0, image_size, image_size], x_centers(2), scr.yCenter-round(door_size*0.65));

% similarly - door locations
rect_doors = zeros(2,4);
rect_doors(1,:)= CenterRectOnPoint([0,0, door_size, door_size], x_centers(1), scr.yCenter);
rect_doors(2,:)= CenterRectOnPoint([0,0, door_size, door_size], x_centers(2), scr.yCenter);

% create in advance textures for doors
[img,~,alpha] = imread('./img/door1.png');
img(:, :, 4) = alpha;
door1tex = Screen('MakeTexture', scr.main, img); % make opengl texture out of image
[img,~,alpha] = imread('./img/door2.png');
img(:, :, 4) = alpha;
door2tex = Screen('MakeTexture', scr.main, img); % make opengl texture out of image

%----------------------------------------------------------------------
%% trial list
n_trials = 40; % must be even
imageFolder = [pwd, '/img/']; % 
type_list = repmat([{'AB'},{'CD'}],1,n_trials/2);
type_list = type_list(randperm(n_trials));
%type_list = [repmat({'AB'},1,n_trials/2),repmat({'CD'},1,n_trials/2)]; % debug animation

% assign probabilities
if randn>0 % A win more
    if randn>0 % C loses more
        ABCD = [80, 20, -80, -20];
    else
        ABCD = [80, 20, -20, -80];
    end
else % B win more
    if randn>0 % C loses more
        ABCD = [20, 80, -80, -20];
    else
        ABCD = [20, 80, -20, -80];
    end
end

%----------------------------------------------------------------------
%% coin locations
% maximum of 15 coins for 30 trials
coin_size = round(1*ppd);
max_coins = n_trials/2;
x_coins = round(linspace(1.5*coin_size, scr.xres-1.5*coin_size, max_coins));
y_coins = round(scr.yres - coin_size);
rect_coin = zeros(max_coins,4);
for i=1:max_coins
    rect_coin(i,:)= CenterRectOnPoint([0,0, coin_size, coin_size], x_coins(i), y_coins);
end

[token_img,~,alpha] = imread([pwd, '/img/mariostarcoin1.png']);
token_img(:, :, 4) = alpha;
token_tex = Screen('MakeTexture', scr.main, token_img); % make opengl texture out of image

%----------------------------------------------------------------------
%% OK, now run trials

% Make a directory for the results
resultsDir = [pwd '/data/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end

%
if SJ.number > 0
    datFid = fopen([resultsDir filename], 'w');
    fprintf(datFid, 'id_n\tid\tage\tgender\ttrial\tA_val\tB_val\tC_val\tD_val\ttype\tchoice\twin\tscore\trespTime\n');
end

% % Start screen
% instructions = ['Each trial you will have to chose one out of two shapes (one square and one disc).\n\n',...
%                 'One pair of shapes will be red, and will hide a good monster: if you find him he will give you a golden coin!\n',...
%                 'He spends more time behind one of the two shapes, although you do not know in advance whether is the square or the disc.\n\n',...
%                 'The other pair of shapes will be blue, and will hide a bad monster! If you disturb him he will steal one of your gold coins.\n',...
%                 'He also prefer to spend more time behind one of the two shapes, although you do not know it is the square or the disc.\n\n',...
%                 'Choose wisely and try to collect the largest number of golden coins!\n\n',...
%                 'Click on the mouse button to start.'];
%                 
% Screen('TextSize', scr.main, text_size);
% Screen('TextFont', scr.main, 'Arial');
% DrawFormattedText(scr.main, instructions, scr.xCenter - ceil(scr.xCenter/1.2), 'center', scr.white);
% Screen('Flip', scr.main);

% story
if strcmp(reply, 'n')
    story_intro;
end

% wait for a mouse click to start
instructions = 'Click on the mouse button to start!';
Screen('TextSize', scr.main, text_size);
Screen('TextFont', scr.main, 'Arial');
DrawFormattedText(scr.main, instructions, scr.xCenter - ceil(scr.xCenter/1.2), 'center', scr.white);
Screen('Flip', scr.main);
GetClicks(scr.main,0);

points = 0;

if SJ.number < 0 
    n_trials = 15;
end

if save_images
    n_trials = 5;
end

for t = 1:n_trials
    
    % display stimulus
    t_type = char(type_list(t));
    if randn>0
        img_1 = t_type(1);
        img_2 = t_type(2);
    else
        img_1 = t_type(2);
        img_2 = t_type(1);
    end
       
    % 
    Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
    Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
    drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
    drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
    for i = 1:points
        Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
    end
    [~, onsetTime] = Screen('Flip', scr.main);
    if save_images
        imageArray = Screen('GetImage', scr.main);
        imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
        im_counter = im_counter +1;
    end
    
    % collect response
    [resp, label, clickTime] = getMouseResponse([img_1, img_2], rect_img([1,2],:), scr);
    respTime = clickTime - onsetTime;
    
    % deliver reward
    switch label
        case 'A'            
            Q = ABCD(1);
        case 'B'
            Q = ABCD(2);
        case 'C'
            Q = ABCD(3);
        case 'D'
            Q = ABCD(4);
    end
    
    if Q>0
        win = rand(1) <= (Q/100);
    else
        win = rand(1) <= (abs(Q)/100);
        win = -win;
    end
    
    if SJ.number < 0
        if resp==win_resp
            if t_type == 'AB'
                win=1;
            else
                win=-1;
            end
        else
            win=0;
        end
    end 
    
    points = points + win; % update points
    
    avoid_loss_anim = 0;
    if points < 0 
        points = 0;
        avoid_loss_anim = 1;
    end
    
    % this uses bezier curves to animate the motion of the coins
    if win == 1
        
        for i = 1:(points-1)
            Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
        end
        Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
        Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
        drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
        drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
        drawSmiley(scr.main, [x_centers(resp), scr.yCenter], round(1*ppd), 100, 100);
        Screen('Flip', scr.main);
        if save_images
            imageArray = Screen('GetImage', scr.main);
            imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
            im_counter = im_counter +1;
        end
        
        % draw path
        [x_path, y_path] = bezierCurve2(x_centers(resp),scr.yCenter, x_coins(points),y_coins, 30);
        for i = 1:length(x_path)
            Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
            Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
            drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
            drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
            Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
            for i = 1:(points-1)
                Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
            end
            drawSmiley(scr.main, [x_centers(resp), scr.yCenter], round(1*ppd), 100, 100);
            Screen('Flip', scr.main);
            if save_images
                imageArray = Screen('GetImage', scr.main);
                imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
                im_counter = im_counter +1;
            end
        end
        
        WaitSecs(isiTimeSecs);
        
    elseif win == -1
        
        if ~avoid_loss_anim
            for i = 1:(points+1)
                Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
            end
            Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
            Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
            drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
            drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
            drawSmiley(scr.main, [x_centers(resp), scr.yCenter], round(1*ppd), 1, 100);
            Screen('Flip', scr.main);
            if save_images
                imageArray = Screen('GetImage', scr.main);
                imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
                im_counter = im_counter +1;
            end
            
            % draw path
            [x_path, y_path] = bezierCurve2(x_coins(points+1),y_coins, x_centers(resp),scr.yCenter, 30);
            for i = 1:length(x_path)
                Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
                Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
                drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
                drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
                Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
                for i = 1:points
                    Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
                end
                drawSmiley(scr.main, [x_centers(resp), scr.yCenter], round(1*ppd), 1, 100);
                Screen('Flip', scr.main);
                if save_images
                    imageArray = Screen('GetImage', scr.main);
                    imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
                    im_counter = im_counter +1;
                end
            end
        else
            Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
            Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
            drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
            drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
            for i = 1:points
                Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
            end
            
            drawSmiley(scr.main, [x_centers(resp), scr.yCenter], round(1*ppd), 1, 100);
            Screen('Flip', scr.main);
            if save_images
                imageArray = Screen('GetImage', scr.main);
                imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
                im_counter = im_counter +1;
            end
        end
        WaitSecs(isiTimeSecs);
        
    else
        
        Screen('DrawTexture', scr.main, door2tex, [], rect_doors(resp,:)); 
        Screen('DrawTexture', scr.main, door1tex, [], rect_doors(nonselected(resp),:)); 
        drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
        drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
        for i = 1:points
            Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
        end
        Screen('Flip', scr.main);
        if save_images
            imageArray = Screen('GetImage', scr.main);
            imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
            im_counter = im_counter +1;
        end
    end
    
    % wait for a mouse click to continue
    WaitSecs(isiTimeSecs);

    if SJ.number > 0
        dataline = sprintf('%s%i\t%i\t%i\t%i\t%i\t%s\t%s\t%i\t%i\t%2f\n', info_str, t,ABCD(1),ABCD(2),ABCD(3),ABCD(4),t_type,label,win,points,respTime);
        fprintf(datFid, dataline);
    end
    
    for i = 1:(points)
        Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
    end
    Screen('Flip', scr.main);
    WaitSecs(isiTimeSecs*3);
    if save_images
        imageArray = Screen('GetImage', scr.main);
        imwrite(imageArray, sprintf('./task_screenshots/im%i.jpg',im_counter));
        im_counter = im_counter +1;
    end
    
end

%----------------------------------------------------------------------
%% close data file
if SJ.number > 0
    fclose(datFid);
end

%----------------------------------------------------------------------
%% final feedback and end screen
for i = 1:points
    Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
end
Screen('TextSize', scr.main, text_size);
Screen('TextFont', scr.main, 'Arial');
if SJ.number >= 0 
    DrawFormattedText(scr.main, ['The end! Thanks for participanting.\n\nYou have gained ', num2str(round(points)) ,' coins!\n \n(click mouse to exit)'], scr.xCenter - ceil(scr.xCenter/1.2), scr.yCenter, scr.white);
else
    DrawFormattedText(scr.main, ['End of the practice trials!\n\n(click mouse to exit)'], scr.xCenter - ceil(scr.xCenter/1.2), scr.yCenter, scr.white);
end
Screen('Flip', scr.main);
GetClicks(scr.main,0);
WaitSecs(0.2);

%----------------------------------------------------------------------
%% Close the onscreen window
Screen('CloseAll');

%end % end of main function
