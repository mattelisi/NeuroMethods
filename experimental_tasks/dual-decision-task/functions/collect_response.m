function [rr, acc, tResp] = collect_response(side, leftkey,rightkey, tOff)
% collect response
% play sound if wrong

FlushEvents('KeyDown');

while 1
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftkey) || keycode(rightkey))
        tResp = secs - tOff;
        if keycode(leftkey)
            resp = -1;
        else
            resp = 1;
        end
        rr = (resp +1)/2;
        break;
    end
end

while KbCheck(-1); end

if resp==side
    acc = 1;
else
    acc = 0;
end