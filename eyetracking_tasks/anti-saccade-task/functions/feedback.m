
function feedback(str,x,y,scr,visual)

bounds = Screen(scr.main,'TextBounds',str);

pt = 0.025*length(str); % presentation time
x  = x-bounds(3)/2;     % x position
y  = y-bounds(4)/2;     % y position
c  = [0,0,0];    % color
c_start  = [0,0,0];    % color

WaitSecs(0.1);
nBlank = round(0.20*1/scr.fd); % fade out takes 0.2 secs
Screen('FillRect',scr.main,visual.bgColor);
Screen(scr.main,'Drawtext',str,x,y,c);
vbl = Screen(scr.main,'Flip');
WaitSecs(round(pt/scr.fd)*scr.fd - scr.fd);
for i = 1:nBlank
	c = round(c_start(1)+visual.bgColor(1)*(i/nBlank));
    %c = round(c(1)*(nBlank-i)/nBlank);
	 % rubber([x y x+width y+const.FONT_SIZE]);
	Screen(scr.main,'Drawtext',str,x,y,c);	
    Screen(scr.main,'Flip',vbl + (i-0.5)*scr.fd);
end
Screen(scr.main,'Flip');