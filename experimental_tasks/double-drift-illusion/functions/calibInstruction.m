% Calibration instruction
systemFont = 'Courier';
systemFontSize = 24;
textMessage = ['Calibration. \n\n',...
    '"c", then "ENTER", to start calibration \n',...
    '"v", then "ENTER", to start validation \n\n',...
    'Press any key to begin, then ESC when finished.\n',...
    '(please do NOT press any other key during calibration)'];

Screen('TextSize', scr.main, systemFontSize);
Screen('TextFont', scr.main, systemFont);
Screen('FillRect', scr.main,visual.bgColor);

DrawFormattedText(scr.main, textMessage, 'center', 'center', visual.fgColor,70);
Screen('Flip', scr.main);
SitNWait;
