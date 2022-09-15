function design = genDesign(sess, sjnum, dual_decision, vpcode)
% Set experiment details - confidence dual-decision
% Matteo Lisi

%% session balancing
design.dual_decision = dual_decision;
if ~design.dual_decision
    design.n_trials = 150;
else
    design.n_trials = 300;
end

% counterbalance order
design.lines_first = all([mod(sjnum,2), mod(sess,2)]==[0,0]) || all([mod(sjnum,2), mod(sess,2)]==[1,1]);

%% practice?
design.practice.n_trials = 10;
design.practice.range_coherence = [0.6, 0.95];
design.practice.range_tilt = [8, 16];

%% stimuli levels
if ~design.dual_decision
    design.maxCoherence = 0.95;
    design.maxTilt = 12;
else
    noisefile = sprintf('./data/%s/%s_noise.mat',vpcode(1:4),vpcode(1:4));
    if isfile(noisefile)
        load(noisefile,'out');
    else
        out = estimate_noise(vpcode, sess);
    end
    if abs(out.orientation.bias)>out.orientation.sigma
        warning('Control task show large bias in orientation task!')
    end
    if abs(out.motion.bias)>out.motion.sigma
        warning('Control task show large bias in motion task!')
    end
    design.maxCoherence = out.motion.sigma * 2;
    design.maxTilt = out.orientation.sigma * 2;
end

if design.maxCoherence>1
   design.maxCoherence = 1;
end

%% stimuli presentation settings
design.stimDuration = 0.3;

%% generate trial list
for i=1:design.n_trials
    %trial(i).right = (sign(randn(1))+1)/2;
    trial(i).right = randn(1)>0; % cause binornd is in Stat and Machine Learning toolbox
    if trial(i).right
        trial(i).ch = rand(1)*design.maxCoherence;
        trial(i).mu = rand(1)*design.maxTilt;
        trial(i).side = 1;
    else
        trial(i).ch = rand(1)*design.maxCoherence;
        trial(i).mu = rand(1)*design.maxTilt;
        trial(i).side = -1;
    end
end

%% exp structure
design.nTrialsInBlock = 50;
design.nBlocks = ceil(design.n_trials/design.nTrialsInBlock);

design.iti = 0.6; % inter trial interval
design.idi = 0.4; % inter decision interval

% generate blocks
trial = trial(randperm(design.n_trials));
beginB=1; endB=min([design.nTrialsInBlock,design.n_trials]);
for i = 1:design.nBlocks
    design.b(i).trial = trial(beginB:endB);
    beginB  = beginB + design.nTrialsInBlock;
    endB    = endB   + design.nTrialsInBlock;
end
