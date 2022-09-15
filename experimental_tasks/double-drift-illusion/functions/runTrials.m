function [design] = runTrials(design, datFile, scr, visual, const)
%
% perpceptual task noise
% (no eyetracking here)
%
% - manual adjustments
%

% hide cursor 
HideCursor;

% preload important functions
% NOTE: adjusting timer with GetSecsTest
% has become superfluous in OSX
Screen(scr.main, 'Flip');
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(datFile, 'w');

% unify keynames for different operating systems
KbName('UnifyKeyNames');


for b = 1:design.nBlocks
    block = design.blockOrder(b); 

    if isfield(design.b(b),'train')
        ntTrain = length(design.b(b).train);
        ntTrial = length(design.b(b).trial);
    else
        ntTrain = 0;
        ntTrial = length(design.b(b).trial);
    end
    ntt = ntTrain + ntTrial;

    
    % instructions
    systemFont = 'Arial'; % 'Courier';
    systemFontSize = 19;
    GeneralInstructions = ['Block ',num2str(b),' of ',num2str(design.nBlocks),'. \n\n',...
        'Press any key to begin.'];
    Screen('TextSize', scr.main, systemFontSize);
    Screen('TextFont', scr.main, systemFont);
    Screen('FillRect', scr.main, visual.bgColor);
    
    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor,70);
    Screen('Flip', scr.main);
    
    SitNWait;
    
    % test trials
    t = 0;
    while t < ntt
        
        t = t + 1;
        trialDone = 0;
        if t <= ntTrain
            trial = t;
            if trial == 1
            end
            td = design.b(b).train(trial);
        else
            trial = t-ntTrain;
            td = design.b(b).trial(trial);
        end

        %%
        if trial==1	|| ~mod(trial,design.nTrlsBreak)        % 
            strDisplay(sprintf('%i out of %i trials finished. Press any key to continue',trial-1,ntt),scr.centerX, scr.centerY,scr,visual);
            Screen('Flip', scr.main);
            SitNWait;
        end

        %
        drawFixation(visual.fixCkCol,td.fixLoc,scr,visual);
        Screen('Flip', scr.main);
        WaitSecs(0.5);
        
        %% RUN SINGLE TRIAL
        
        [data] = runSingleTrial(td, scr, visual, const, design);
        
        dataStr = sprintf('%i\t%i\t%s\n',b,trial,data); % print data to string
        
        fprintf(1,dataStr);

        % go to next trial if fixation was not broken
        if strcmp(data,'tooSlow')
            trialDone = 0;

            feedback('No response.',td.fixLoc(1),td.fixLoc(2),scr,visual);
        else
            trialDone = 1;

            fprintf(datFid,dataStr);                    % write data to datFile
         
        end

        fprintf(1,'\nTrial %i done',t-ntTrain);

        if ~trialDone && (t-ntTrain)>0
            ntn = length(design.b(b).trial)+1;  % new trial number
            design.b(b).trial(ntn) = td;        % add trial at the end of the block
            ntt = ntt+1;

            fprintf(1,' ... trial added, now total of %i trials',ntt);
        end
        WaitSecs(design.iti);
        
        
        %%
        
        
        if const.saveMovie
            if trial > const.nTrialMovie
                return
            end
        end
        
    end
end

fclose(datFid); % close datFile

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'DrawText','Thanks, you have finished this part of the experiment.',100,100,visual.fgColor);
Screen(scr.main,'Flip');
ShowCursor;

WaitSecs(1);
cleanScr;
