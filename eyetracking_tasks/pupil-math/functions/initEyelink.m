function [el, error]=initEyelink(vpcode,visual, const, scr)
%
% Initializes eyeLink-connection, creates edf-file
% and writes experimental parameters to edf-file
% 
% 2008 by Martin Rolfs
% 2012 update, Matteo Lisi
%

%---------------------%
% define edf-filename %
%---------------------%
edffilename = strcat(vpcode,'.edf');


% dummymode (mouse is tracked) or eyelink connected (eyes are tracked)
error=0;
if ~const.TEST
	if (Eyelink('initialize') ~= 0)
        Eyelink('initializedummy');
	end
else
	Eyelink('initializedummy');
end


% create edf-file
i = Eyelink( 'openfile', edffilename);
if i~=0
	printf('Cannot create EDF file ''%s'' ', edffilename);
	Eyelink( 'Shutdown');
	return;
end

% set eyelink defaults
el=EyelinkInitDefaults(scr.main);

%---------------------------------------%
% general information on the experiment %
%---------------------------------------%
Eyelink('command', 'add_file_preamble_text ''anti-saccade task by Matteo Lisi''');

%  SET UP TRACKER CONFIGURATION
Eyelink('command', 'calibration_type = HV9');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,BUTTON');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
Eyelink('command', 'heuristic_filter = 1 1');

Eyelink('command', 'calibration_area_proportion 0.8 0.8'); % width - height
Eyelink('command', 'validation_area_proportion 0.8 0.8');

Eyelink('command', 'calibration_corner_scaling 0.6'); % gives corner-center distance relative (prop.)
Eyelink('command', 'validation_corner_scaling 0.6');


%% Set parser values
Eyelink('command', 'recording_parse_type = GAZE');
Eyelink('command', 'saccade_velocity_threshold = 30');
Eyelink('command', 'saccade_acceleration_threshold = 8000');
Eyelink('command', 'saccade_motion_threshold = 0');

%% Set pupil Tracking model in camera setup screen  (no = centroid. yes = ellipse)
Eyelink('command', 'use_ellipse_fitter =  NO');

%% set sample rate in camera setup screen
Eyelink('command', 'sample_rate = %d',1000);

%--------------------------------------------------------%
% write descriptions of the experiment into the edf-file %
%--------------------------------------------------------%
Eyelink('message', 'BEGIN OF DESCRIPTIONS');
Eyelink('message', 'Subject code: %s', vpcode);
Eyelink('message', 'END OF DESCRIPTIONS');

%--------------------------------------%
% modify a few of the default settings %
%--------------------------------------%
el.backgroundcolour = visual.bgColor;		% background color when calibrating
el.foregroundcolour = visual.fgColor;        % foreground color when calibrating
el.calibrationfailedsound = 0;				% no sounds indicating success of calibration
el.calibrationsuccesssound = 0;

% test mode of eyelink connection
status = Eyelink('isconnected');
switch status
    case -1
        fprintf(1, 'Eyelink in dummymode.\n\n');
    case  0
        fprintf(1, 'Eyelink not connected.\n\n');
    case  1
        fprintf(1, 'Eyelink connected.\n\n');
end

if Eyelink('isconnected')==el.notconnected
    Eyelink('closefile');
    Eyelink('shutdown');
    Screen('closeall');
    return;
end

error=el.ABORT_EXPT;