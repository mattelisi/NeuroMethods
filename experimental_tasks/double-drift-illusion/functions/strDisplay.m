function strDisplay(str,x,y,scr,visual)
%
%
%

bounds = Screen(scr.main,'TextBounds',str);

x  = x-bounds(3)/2;     % x position
y  = y-bounds(4)/2;     % y position
c  = visual.fgColor;    % color

Screen(scr.main,'Drawtext',str,x,y,c);