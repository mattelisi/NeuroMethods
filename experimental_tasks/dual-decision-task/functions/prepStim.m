function[visual] = prepStim(scr)
%
% Prepare display parameters
% set constant stimulus properties
%

%% general display settings
visual.ppd = va2pix(1,scr);   % pixel per degree
visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);
visual.bgColor = ceil((visual.black + visual.white) / 2);
visual.darkGrey = ceil((visual.black + visual.white) / 3);
visual.red = [220, 0 0];
visual.green = [0, 190 0];
visual.fgColor = visual.white;

Screen('FillRect', scr.main,visual.bgColor);
Screen('Flip', scr.main);

%% stimulus
visual.textureWidth = round(8 * visual.ppd);
visual.targetEccentricity = round(6 * visual.ppd); % it says 'target' but 'placeholder' should probably be more correct
visual.target_location_left = [scr.centerX, scr.centerY, scr.centerX, scr.centerY] - [visual.targetEccentricity 0 visual.targetEccentricity 0];
visual.target_location_right = [scr.centerX, scr.centerY, scr.centerX, scr.centerY] + [visual.targetEccentricity 0 visual.targetEccentricity 0];
visual.target_location_up = [scr.centerX, scr.centerY, scr.centerX, scr.centerY] - [0 ceil(visual.textureWidth/1.45) 0 ceil(visual.textureWidth/1.45)];
visual.targetSize = round(0.5 * visual.ppd);
visual.stimRect = [([scr.centerX, scr.centerY] -round(visual.textureWidth/2)) ([scr.centerX, scr.centerY] +round(visual.textureWidth/2))];

%% specific parameters of random dot stimulus
visual.dots.nDots = 200;                                                                        % Number of dots in the field
visual.dots.speed = visual.ppd * 4;                                                             % Speed of the dots (degrees/second)
visual.dots.lifetime = 5;                                                                       % Number of frames for each dot to live
visual.dots.apertureSize =[visual.textureWidth, visual.textureWidth] - round(0.1 * visual.ppd); % [x,y] size of elliptical aperture (degrees)
visual.dots.center = [scr.centerX, scr.centerY];                                                % [x,y] Center of the aperture (degrees)
visual.dots.color = [repmat(visual.white,visual.dots.nDots/2,3);...
                      repmat(visual.black,visual.dots.nDots/2,3)];                              % Color of the dot field [r,g,b] from 0-255
visual.dots.size = round(0.1 * visual.ppd);                                                     % Size of the dots (in pixels)

% these fields are populated trial-by-trial
% dots.coherence       % Coherence from 0 (incoherent) to 1 (coherent)
% dots.direction       % Direction 0-360 clockwise from upward

%% specific parameters for line stimulus
visual.nLines = 150;
visual.lineLength = round(0.7 * visual.ppd);
visual.lineWidth = round(0.04 * visual.ppd);
visual.sdLines = 15;

%% feedback sound
% ok that's not a 'visual' property but nevermind
fs= 4096;  % sampling frequency
amp=0.8;
freq=390; % F5
duration=0.4;
values=0:(1/fs):duration;
visual.sound_acc0=amp*sin(2*pi* freq*values);
visual.sound_fs = fs;

%% text
visual.textSize = round(visual.ppd*0.5);

%% rubbish
% visual.scrCenter = [scr.centerX scr.centerY scr.centerX scr.centerY];
% visual.fixCkRad = round(1.5*visual.ppd);    % fixation check radius
% visual.fixCkCol = visual.black;      % fixation check color
% visual.fixCol = 10;

%% gamma correction
% if const.gammaLinear
%     load(const.gamma);
%     % load(const.gammaRGB);
%     
%     % prepare and load lookup gamma table
%     luminanceRamp = linspace(LR.LMin, LR.LMax, 256);
%     invertedRamp = LR.LtoVfun(LR, luminanceRamp);
%     invertedRamp = invertedRamp./255;
%     
%     inverseCLUT = repmat(invertedRamp',1,3);
%     % save gammaTable_greyscale.mat inverseCLUT
%     Screen('LoadNormalizedGammaTable', scr.main, inverseCLUT);
%     
%     visual.bgColor = 80;
%     visual.bgColorLuminance = LR.VtoLfun(LR, invertedRamp(visual.bgColor)*255);
% end

%% set priority of window activities to maximum
priorityLevel=MaxPriority(scr.main);
Priority(priorityLevel);
