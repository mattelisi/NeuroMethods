function res = checkGazeAtPoint(gp,pos,rad)
% 
%     Check if current gaze point is within a radius of [rad] pixel from 
%     selected position [pos]=[x,y]
%
%       typically rad = visual.fixCkRad
%

if sqrt((gp(1)-pos(1))^2+(gp(2)-pos(2))^2) < rad
    res = 1;
else
    res = 0;
end