function[visual] = prepStim(scr, const, design)
%
% perceptual task with noise patches
%
% Set display parameters, colors, etc. etc. 
%

visual.ppd = va2pix(1,scr);   % pixel per degree

% colors
visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);
visual.bgColor = round((visual.black + visual.white) / 2);     % background color
visual.fgColor = visual.black;

% coordinates
visual.scrCenter = [scr.centerX scr.centerY scr.centerX scr.centerY];

% fixation point
visual.fixCkRad = 2.5*visual.ppd;      % fixation check radius
visual.fixCkCol = visual.black;      % fixation check color
visual.fixCol = 50;

% target
visual.tarSize = 101;
if mod(visual.tarSize,2) == 0
    visual.tarSize = visual.tarSize+1;
end
visual.res = 1*[visual.tarSize visual.tarSize];

% gamma correction
if const.gammaLinear
    load(const.gamma);
    load(const.gammaRGB);
    
    % prepare and load lookup gamma table
    luminanceRamp = linspace(LR.LMin, LR.LMax, 256);
    invertedRamp = LR.LtoVfun(LR, luminanceRamp);
    invertedRamp = invertedRamp./255;
    inverseCLUT = repmat(invertedRamp',1,3);
    % save gammaTable_greyscale.mat inverseCLUT
    
    Screen('LoadNormalizedGammaTable', scr.main, inverseCLUT);
    
    visual.bgColor = 14;
    visual.bgColorLuminance = LR.VtoLfun(LR, invertedRamp(visual.bgColor)*255);
end

% set priority of window activities to maximum
priorityLevel=MaxPriority(scr.main);
Priority(priorityLevel);


 