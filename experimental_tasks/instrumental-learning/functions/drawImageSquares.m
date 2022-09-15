function[] = drawImageSquares(scr, img_name, rect_image)
% draw image into rect (img_name must contain full path to image)
% Matteo Lisi 2018
% modified to keep transparency
[img,~,alpha] = imread(img_name);
img(:, :, 4) = alpha;
imgtex = Screen('MakeTexture', scr.main, img); % make opengl texture out of image
Screen('DrawTexture', scr.main, imgtex, [], rect_image); % draw image