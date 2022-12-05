function reddUp
%
% closes screens, shuts down eyelink, clears working memory
% 
% by Martin Rolfs

% re-enable keyboard
ListenChar(1);

% get eyelink data file on subject computer
%vpnr = vpcode((end-7):end);
%edffilename = strcat(vpnr,'.edf');
status = Eyelink('ReceiveFile');%,edffilename, edffilename, 'Data/');
if status == 0
    fprintf(1,'\n\nFile transfer was cancelled\n\n');
elseif status < 0
    fprintf(1,'\n\nError occurred during file transfer\n\n');
else
    fprintf(1,'\n\nFile has been transferred (%i Bytes)\n\n',status)
end

% Eyelink runterfahren
Eyelink('closefile');
WaitSecs(2.0); % Zeit fur Tracker, alles fertigzubekommen
Eyelink('shutdown');
WaitSecs(2.0);

% Screens schliessen
ShowCursor;
% Screen(visual.main,'Resolution', scr.oldRes);
Screen('CloseAll');

% Speicher aufraumen
clear mex;
clear fun;
home;