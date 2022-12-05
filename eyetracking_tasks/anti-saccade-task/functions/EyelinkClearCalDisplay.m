function EyelinkClearCalDisplay(el)
Screen( 'FillRect',  el.window, el.backgroundcolour );	% clear_cal_display()

% update 27-4-2012
systemFont = 'Courier';
systemFontSize = 24;
text = ['C: calibration\nV: validation\nESC: exit calibration'];
Screen('TextSize', el.window, systemFontSize);
Screen('TextFont', el.window, systemFont);
%DrawFormattedText(el.window, text, 'center', 'center', (el.backgroundcolour+el.foregroundcolour)/2,70);
DrawFormattedText(el.window, text, 20,20, (el.backgroundcolour+el.foregroundcolour)/2,70);
%

Screen( 'Flip',  el.window);