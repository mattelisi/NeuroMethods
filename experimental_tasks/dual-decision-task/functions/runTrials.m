function [design] = runTrials(design, datFile, resDir, scr, visual)
% run experimental blocks

%% get ready
% preload important functions
Screen(scr.main, 'Flip');
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(sprintf('./%s/%s',resDir,datFile), 'w');

% unify keynames for different operating systems
KbName('UnifyKeyNames');
HideCursor(scr.main);

% text 
Screen('TextSize', scr.main, visual.textSize);
Screen('TextFont', scr.main, 'Arial');

%% practice?
%if isfield(design,'practice')
txtmsg = ['Do you want to run a quick practice (y/n)?'];
Screen('FillRect', scr.main, visual.bgColor);
DrawFormattedText(scr.main, txtmsg, 'center', 'center', visual.fgColor);
Screen('Flip', scr.main);

while 1
    [keyisdown, ~, keycode] = KbCheck(-1);
    if keyisdown && (keycode(KbName('y')) || keycode(KbName('n')))
        if keycode(KbName('y'))
            do_practice = 1;
        elseif keycode(KbName('n'))
            do_practice = 0;
        end
        break;
    end
end

while do_practice
    
    npt = design.practice.n_trials;
    for i = 1:npt
        
        ptd.ch = rand(1)*(design.practice.range_coherence(2)-design.practice.range_coherence(1)) + design.practice.range_coherence(1);
        ptd.mu = rand(1)*(design.practice.range_tilt(2)-design.practice.range_tilt(1)) + design.practice.range_tilt(1);
        ptd.side = sign(randn(1));
        
        runSingleTrial(ptd, scr, visual, design);
        
    end
    
    txtmsg = ['Practice trials completed.\n\n Continue to main experiment (y) or repeat practice (r)?'];
    Screen('FillRect', scr.main, visual.bgColor);
    DrawFormattedText(scr.main, txtmsg, 'center', 'center', visual.fgColor);
    Screen('Flip', scr.main);
    
    while 1
        [keyisdown, ~, keycode] = KbCheck(-1);
        if keyisdown && (keycode(KbName('y')) || keycode(KbName('r')))
            if keycode(KbName('y'))
                do_practice = 0;
            end
            break;
        end
    end
    
end
%end

%% experimental blocks
for b = 1:design.nBlocks
    
    ntt = length(design.b(b).trial);

    %% block instructions
    GeneralInstructions = ['Block ',num2str(b),' of ',num2str(design.nBlocks),'. \n\n',...
        'Press any key to begin.'];
    Screen('FillRect', scr.main, visual.bgColor);
    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor);
    Screen('Flip', scr.main);
    
    SitNWait;
    
    % trial loop
    t = 0;
    while t < ntt
        
        t = t + 1;
        td = design.b(b).trial(t);
        
        % run single trial
        [data1, data2] = runSingleTrial(td, scr, visual, design);
                
        % print data to string
        dataStr1 = sprintf('%s\t%i\t%i\t%i\t%i\t%s',datFile, b, t, design.dual_decision, design.lines_first, data1); 
        dataStr2 = sprintf('%s\t%i\t%i\t%i\t%i\t%s',datFile, b, t, design.dual_decision, design.lines_first, data2); 
        
         % write data to datFile
        fprintf(datFid,dataStr1);
        fprintf(datFid,dataStr2);
        
        WaitSecs(design.iti);       % inter-trial interval
        
    end
end

%% save data and say goodbye
fclose(datFid); % close datFile

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'DrawText','Thanks, you have finished this part of the experiment.',100,100,visual.fgColor);
Screen(scr.main,'Flip');
WaitSecs(1);
SitNWait;
ShowCursor('Arrow',scr.main);

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'Flip');
