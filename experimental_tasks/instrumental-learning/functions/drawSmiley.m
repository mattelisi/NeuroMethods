function drawSmiley(window, location, width, score, maxscore)
% 
% This function draw a "parametrical" smiley
% inputs:
% - location: [x, y]
% - width: radius of face, in pixels
% - score: this determine how 'happy' is the smile
% - maxscore: maximum score -> max happiness
%
% Matteo Lisi, 2018

rect_face = [location(1)-width, location(2)-width, location(1)+width, location(2)+width];
penwidth = round(width/20);

L = round(sqrt(width^2 *1/8));
xyeyes = [location(1)-L, location(1)+L; location(2)-L, location(2)-L];

% colormap from blu (sad) to yellow (happy)
%T = round([linspace(0,255,100)', linspace(0,255,100)', linspace(255,0,100)']);
T = round([linspace(0,255,100)', linspace(120,255,100)', linspace(10,0,100)']);

% parameters for "mouth"
if score/maxscore > 0.5
    R = width*(4 - 1/3)*(1-score/maxscore) + width*1/3;
    locmth = [location(1), location(2)+width*1/2-R];
    beta = 2*asin(width/(2*R))/pi*180;
    start_beta = 180-beta/2;
else
    R = width*(4 - 1/2)*(score/maxscore) + width*1/2;
    locmth = [location(1), location(2)+width*1/2+R];
    beta = 2*asin(width/(2*R))/pi*180;
    start_beta = -beta/2;
end
rect_mth = [locmth(1)-R, locmth(2)-R, locmth(1)+R, locmth(2)+R];

% draw everything
Screen('FillOval', window, T(ceil(score/maxscore*100),:), rect_face);
Screen('FrameArc',  window,[0,0,0], rect_mth, start_beta, beta, penwidth);
Screen('DrawDots', window, xyeyes, 4*penwidth, [0,0,0],[],2);