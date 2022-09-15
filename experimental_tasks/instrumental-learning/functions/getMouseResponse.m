function[resp, label, time] = getMouseResponse(label_squares, rect_squares, scr)
% wait for mouse response and return answer
% Matteo Lisi 2018
ShowCursor('CrossHair');
SetMouse(scr.xCenter, round(2/3*scr.yres));
resp = 0;
while ~resp
    [~,x_m,y_m,whichButton] = GetClicks(scr.main,0);
    if whichButton==1
        time = GetSecs;
        for i=1:size(rect_squares,1)
            if IsInRect(x_m,y_m,rect_squares(i,:))
                resp=i;
                label = char(label_squares(i));
            end
        end
    end
end