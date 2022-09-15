function [tOff, tOn, meanTilt, sdTilt] = present_lines(scr,visual, design, side, decision_order, mu)
% present random array of lines
% - decision order is a string
% - mu is tilt from vertical in degree (positive = righward)
% Matteo Lisi, 2019

% generate texture
[tex , sdTilt, meanTilt] = makeNoisyLinesTex(scr.main, visual, (-side*mu+90)/180*pi, visual.sdLines/180*pi ,visual.nLines ,visual.lineLength, visual.lineWidth, visual.textureWidth);
while sign(90 - meanTilt)~= side
    [tex , sdTilt, meanTilt] = makeNoisyLinesTex(scr.main, visual, (-side*mu+90)/180*pi, visual.sdLines/180*pi ,visual.nLines ,visual.lineLength, visual.lineWidth, visual.textureWidth);
end
meanTilt = -(meanTilt-90);

% pre-stimulus
draw_placeholders(decision_order, scr, visual);
tFix = Screen('Flip', scr.main,0);
WaitSecs(design.idi);

% display stimulus
draw_placeholders(decision_order, scr, visual);
Screen('DrawTexture', scr.main, tex,[],visual.stimRect);
tOn = Screen('Flip', scr.main, 0);

% remove and take offset time for RT
draw_placeholders(decision_order, scr, visual);
tOff = Screen('Flip', scr.main, tOn + design.stimDuration);

% close active textures
Screen('Close', tex);
