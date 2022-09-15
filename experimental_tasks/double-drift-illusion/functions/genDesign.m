function [design] = genDesign(visual,scr,as)
%
% infinite regress - perceptual task with noise patches - multiple staircases
% 
% Matteo Lisi, 2016
% 


%% target parameters

% spatial
design.ecc = 10;                 % eccentricity of the trajectory midpoint (degree of visual angle)
design.tarFreq = 0.2;            % wavelength (sort of..) of the top noise functions
design.octaves = 3;              % number of noise layers
design.sigma = 0.2;             % sigma of the gaussian envelope (sigma = FWHM / 2.35)
design.constrast = 1;            % gabor's contrast [0 - 1]

% motion & temporal
design.envelope_speed = 2.8889;      % degree/sec. (2.6*2)/1.8
design.drifting_speed = 3;      % (cycles of the carrier)/sec.
design.control_speed = 1.5;      
design.trajectoryLength = 3;    % degree of visual angle

design.fixDur = 0.400;          % minimum fixation duration [s]
design.fixDuJ = 0.200;          % additional fixation duration jitter [s]
design.motionType = 'triangular';   % allowed: triangular, sinusoidal

% conditions 
design.conditions = [1 -1 0];      % -1=CW ; 1 CCW; 0=control
design.maxTilt = 70;

% method 
design.alpha_initial = [40];     % initial point of before adjustments
design.alpha_step = 1;
                                
%% other parameter
design.fixoffset = visual.ppd*[-5, 0]; % from screen center
design.fixJtStd = 0;

% task structure
design.nTrialsInBlock = 40;
design.nTrlsBreak = 200;    % number of trials between breaks, within a block
design.iti = 0.2;
design.totSession = 1;

% timing
design.preRelease = scr.fd/3;           % must be half or less of the monitor refresh interval
design.fixDur = 0.400;                  % minimum fixation duration [s]
design.fixDuJ = 0.200;                  % additional fixation duration jitter [s]
design.maxRT  = 10;

%% trials list
t = 0;
for alpha = design.alpha_initial
for tarFreq = design.tarFreq
for contrast = design.constrast
for sigma = design.sigma
for env_speed = design.envelope_speed
for drift_speed = design.drifting_speed
for cond = design.conditions
for trajLength = design.trajectoryLength
for initPos = [1 -1]
for ecc = design.ecc
    
    t = t+1;
    
    % settings
    if cond~=0
        trial(t).alpha = cond*alpha;
        %trial(t).initAlpha = cond*alpha;
    else
        %trial(t).alpha = sign(randn(1))*alpha;
        trial(t).alpha = initPos*alpha;
        %trial(t).initAlpha = cond*alpha;
    end

    trial(t).tarFreq = tarFreq * visual.ppd;    % in trial list the measures are in pixels
    trial(t).sigma = sigma * visual.ppd;        % 
    
    trial(t).contrast = contrast;
    trial(t).env_speed = env_speed;
    trial(t).drift_speed = drift_speed;
    trial(t).trajLength = trajLength;
    trial(t).initPos = initPos;
    trial(t).ecc = ecc;
    trial(t).cond = cond;

    %
    trial(t).fixDur = round((design.fixDur + design.fixDuJ*rand)/scr.fd)*scr.fd;
    trial(t).fixLoc = [scr.centerX scr.centerY] + design.fixoffset + round(randn(1,2)*design.fixJtStd*visual.ppd);
    
end
end
end
end
end
end
end
end
end
end

design.totTrials = t;

% select trial for session
as = mod(as,design.totSession); 
if as==0; as=design.totSession; end

design.actualSession = as;

sessIndex = (repmat(1:design.totSession,1,ceil(design.totTrials/design.totSession)));
trial = trial(sessIndex==as);

% random order
r = randperm(length(trial));
trial = trial(r);

% generate blocks
design.nBlocks = 1;
design.b(1).trial = trial;
design.blockOrder = 1;

% design.nBlocks = length(trial)/design.nTrialsInBlock;
% design.blockOrder = 1:design.nBlocks;
% 
% b=1; beginB=b; endB=design.nTrialsInBlock;
% 
% for i = 1:design.nBlocks
%     design.b(i).trial = trial(beginB:endB);
%     beginB  = beginB + design.nTrialsInBlock;
%     endB    = endB   + design.nTrialsInBlock;
% end



