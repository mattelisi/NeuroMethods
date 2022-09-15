function [tOff, tOn, meanTilt, sdTilt] = present_RDM(scr,visual, design, side, decision_order, coherence)
% present random array of lines
% - decision order is a string
% - coherence is (0, 1]
% Matteo Lisi 2019

% prepare stimulus settings
dots = visual.dots;
dots.coherence = coherence;
if side>0
    dots.direction = 90;
else
    dots.direction = -90;
end
meanTilt = NaN;
sdTilt = NaN;

% pre-stimulus
draw_placeholders(decision_order, scr, visual);
tFix = Screen('Flip', scr.main,0);
WaitSecs(design.idi);

% display stimulus
tOn = tFix + design.idi;
%movingDots(scr, dots, design.stimDuration, visual, decision_order, visual.target_location_left, visual.target_location_right, visual.targetSize, visual.textureWidth);
movingDots(scr, dots, design.stimDuration, visual, decision_order);

% remove and take offset time
draw_placeholders(decision_order, scr, visual);
tOff = Screen('Flip', scr.main, 0);
