function[] = drawImageSquares(scr, img_name, rect_image)
% draw image into rect (img_name must contain full path to image)
% Matteo Lisi 2018
img = imread(img_name);
imgtex = Screen('MakeTexture', scr.main, img); % make opengl texture out of image
Screen('DrawTexture', scr.main, imgtex, [], rect_image); % draw image
