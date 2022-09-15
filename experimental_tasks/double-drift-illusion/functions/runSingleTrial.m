function [data] = runSingleTrial(td, scr, visual, const, design)
%
% perceptual task - noise patches (no eyetracking here)
%
% td = trial design
%
% Matteo Lisi, 2016
% 


%% TRIAL PREP.

% clear keyboard buffer
FlushEvents('KeyDown');

% define response keys
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');
OKkey = 40; %KbName('Return');

% keyisdown=0;
% while ~keyisdown
%     [keyisdown, secs, keycode] = KbCheck(-1);
% end

HideCursor;

% determine motion parameters
[td, nFrames] = compMotionPar (td,scr,design);

% predefine boundary information
cxm = td.fixLoc(1);
cym = td.fixLoc(2);

% make noise textures for each frame
motionTex = zeros(1, nFrames);
if td.cond~=0
    noiseimg = generateNoiseImage(design,nFrames,visual,td, scr.fd);
    m = framesIllusion(design, visual, td, nFrames, noiseimg, scr.fd);
else
    noiseimg = generateNoiseVolume(design,nFrames,visual,td, scr.fd);
    m = framesControl(design, visual, td, nFrames, noiseimg, scr.fd);
end
for i=1:nFrames
    motionTex(i)=Screen('MakeTexture', scr.main, m(:,:,i));
end
seq = 1:nFrames;
sqShift = round(nFrames/4);
seq = circshift(seq, [0, -sqShift]);

% rect coordinates for texture drawing
pathRects = detRect(visual.ppd*td.tarPos(:,1) + cxm + visual.ppd*td.ecc, visual.ppd*td.tarPos(:,2) + cym, visual.tarSize);

% set angle for drawing textures
if td.cond>0
    patchAngle =  90 -td.alpha;
else
    patchAngle = -90 -td.alpha;
end
if td.initPos==-1; patchAngle = 180+patchAngle; end

% predefine time stamps
tBeg    = NaN;
tResp   = NaN;
tEnd    = NaN;

trialPhase = 1;   % 1 = fixation phase (before cue), 2 = response (after second flash)

% prepare for response adjustments
timeIndex = linspace(0, 1, round(((td.trajLength*2) / td.env_speed)/scr.fd));
timeIndex(end) = [];
path_alpha = 90 + td.alpha;

% flags/counters
ex_fg = 0;      % 0 = ongoing; 1 = response OK; 2 = fix break; 3 = too slow
cycle = 0;

% draw fixation stimulus
drawFixation(visual.fixCol,td.fixLoc,scr,visual);
tFix = Screen('Flip', scr.main,0);

if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.fixDur/scr.fd)); 
end

tFlip = tFix + td.fixDur;
WaitSecs(td.fixDur - 2*design.preRelease);  

%% TRIAL

while ~ex_fg
    
    for i = 1:length(td.tarPos)
        
        % check keyboard
        [keyisdown, secs, keycode] = KbCheck(-1);
        if keyisdown && (keycode(leftkey) || keycode(rightkey) || keycode(OKkey))
            if keycode(OKkey)
                if trialPhase == 2 
                    ex_fg = 1;    % successful trial (response collected)
                    tResp = secs;
                end
            elseif keycode(leftkey)
                path_alpha = path_alpha+design.alpha_step;
                if path_alpha>(design.maxTilt+90); path_alpha=(design.maxTilt+90); end
                if path_alpha<(90-design.maxTilt); path_alpha=(90-design.maxTilt); end
                [pathRects, patchAngle] = recomputeRect (timeIndex,path_alpha,visual,td,cxm,cym);
            elseif keycode(rightkey)
                path_alpha = path_alpha-design.alpha_step;
                if path_alpha>(design.maxTilt+90); path_alpha=(design.maxTilt+90); end
                if path_alpha<(90-design.maxTilt); path_alpha=(90-design.maxTilt); end
                [pathRects, patchAngle] = recomputeRect (timeIndex,path_alpha,visual,td,cxm,cym);
            end
        
        end
            
        % drawing first
        if const.demo_static
            Screen('DrawTexture', scr.main, motionTex(seq(1)), [], pathRects(seq(i),:), patchAngle);
        else
            Screen('DrawTexture', scr.main, motionTex(seq(i)), [], pathRects(seq(i),:), patchAngle);
        end
        drawFixation(visual.fixCol,td.fixLoc,scr,visual);
        Screen('DrawingFinished',scr.main);
        
        if (cycle + i/length(td.tarPos)) > 0.5 && trialPhase == 1
            trialPhase = 2;
        end
        
        tFlip = Screen('Flip', scr.main, tFlip + scr.fd - design.preRelease);
                
        if i == 1 && cycle == 0; 
            tBeg = tFlip; 
        end

        if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
        
    end % end of a stimulus motion cycle
    
    cycle = cycle + 1;
    
end


%% trial end

switch ex_fg
    
    case 2
        data = 'xxx';
        
    case 3
        data = 'tooSlow';
        
    case 1
        
        WaitSecs(0.2);
        if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.2/scr.fd)); end

        % collect trial information
        trialData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%i',[td.alpha td.env_speed td.drift_speed td.trajLength td.initPos td.ecc td.cond]);
        
        % determine presentation times relative to 1st frame of motion
        timeData = sprintf('%i\t%i\t%i\t%i\t%i',round(1000*([tFix tBeg tResp tEnd]-tBeg)));
        
        % determine response data
        if find(keycode) == leftkey
            resp = -1;
            rr = 1; % recoded response for staircase
        elseif find(keycode) == rightkey
            resp = 1;
            rr = 0;
        end
        
        respData = sprintf('%.2f\t%i',path_alpha, round(1000*(tResp - tBeg)));
        
        % collect data for tab [6 x trialData, 5 x timeData, 1 x respData]
        data = sprintf('%s\t%s\t%s',trialData, timeData, respData);
        
end


% close active textures
Screen('Close', motionTex(:));
WaitSecs(0.2);

