% script that show instructions story


%% presente the doors
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
Screen('Flip', scr.main);
GetClicks(scr.main,0);

%% presente the red symbols
t_type = 'EF';
img_1 = t_type(1);
img_2 = t_type(2);
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
GetClicks(scr.main,0);

%% show nice monster
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
drawSmiley(scr.main, [x_centers(1), scr.yCenter], round(1*ppd), 100, 100);
Screen('Flip', scr.main);
GetClicks(scr.main,0);

% show reward
points=1;
[x_path, y_path] = bezierCurve(x_centers(1),scr.yCenter, x_coins(1),y_coins, 30);
for i = 1:length(x_path)
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:));
    Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:));
    drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
    drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
    Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
%     for i = 1:(points-1)
%         Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
%     end
    drawSmiley(scr.main, [x_centers(1), scr.yCenter], round(1*ppd), 100, 100);
    Screen('Flip', scr.main);
end
GetClicks(scr.main,0);

Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:)); % draw image
Screen('Flip', scr.main);
WaitSecs(1);

% show from opposite side
Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
WaitSecs(0.5);

Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
GetClicks(scr.main,0);

Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
drawSmiley(scr.main, [x_centers(2), scr.yCenter], round(1*ppd), 100, 100);
Screen('Flip', scr.main);
WaitSecs(0.5);

% show reward
points=2;
[x_path, y_path] = bezierCurve(x_centers(2),scr.yCenter, x_coins(2),y_coins, 30);
for i = 1:length(x_path)
    Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:));
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(2,:));
    drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
    drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
    Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
    for i = 1:(points-1)
        Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
    end
    drawSmiley(scr.main, [x_centers(2), scr.yCenter], round(1*ppd), 100, 100);
    Screen('Flip', scr.main);
end
GetClicks(scr.main,0);

%% now the blue doors & bad monster
t_type = 'GH';
img_1 = t_type(1);
img_2 = t_type(2);
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
for i = 1:(points)
    Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
end
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
GetClicks(scr.main,0);

% bad!
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
for i = 1:(points)
    Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
end
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
drawSmiley(scr.main, [x_centers(1), scr.yCenter], round(1*ppd), 1, 100);
Screen('Flip', scr.main);
% GetClicks(scr.main,0);
WaitSecs(0.5);

% show reward
[x_path, y_path] = bezierCurve(x_coins(points),y_coins,x_centers(1),scr.yCenter, 30);
for i = 1:length(x_path)
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:));
    Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:));
    drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
    drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
    Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
    for i = 1:(points-1)
        Screen('DrawTexture', scr.main, token_tex, [], rect_coin(i,:)); % draw image
    end
    drawSmiley(scr.main, [x_centers(1), scr.yCenter], round(1*ppd), 1, 100);
    Screen('Flip', scr.main);
end
GetClicks(scr.main,0);
points = points - 1;

Screen('Flip', scr.main);


% show from opposite side
Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
WaitSecs(0.5);

Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door1tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
Screen('Flip', scr.main);
WaitSecs(0.5);

Screen('DrawTexture', scr.main, token_tex, [], rect_coin(1,:));
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:)); 
Screen('DrawTexture', scr.main, door2tex, [], rect_doors(2,:)); 
drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
drawSmiley(scr.main, [x_centers(2), scr.yCenter], round(1*ppd), 1, 100);
Screen('Flip', scr.main);
WaitSecs(0.5);

% show reward
[x_path, y_path] = bezierCurve(x_coins(1),y_coins,x_centers(2),scr.yCenter,  30);
for i = 1:length(x_path)
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(1,:));
    Screen('DrawTexture', scr.main, door2tex, [], rect_doors(2,:));
    drawImageSquares(scr, [imageFolder, img_1, '.png'], rect_img(1,:));
    drawImageSquares(scr, [imageFolder, img_2, '.png'], rect_img(2,:));
    Screen('DrawTexture', scr.main, token_tex, [], CenterRectOnPoint([0,0, coin_size, coin_size], round(x_path(i)), round(y_path(i))));
    drawSmiley(scr.main, [x_centers(2), scr.yCenter], round(1*ppd), 1, 100);
    Screen('Flip', scr.main);
end
WaitSecs(1.5);


