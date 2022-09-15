function [rt,propErrors]=measureReactionTimes(subject,fractionOfCatchTrials)

% Set global variables (ignore)
global texthandle nErrors

% Open a figure window - this is where all drawing takes place
figure

% Set the name of the figure
set(gcf,'name',sprintf('Measuring reaction times for subject %s',subject))

% Clear the figure
clf
% Draw a black ('k') square
fill([0 0 1 1],[0 1 1 0],'k')
% Set x and y axes to have equal spacing so square looks square (not rectangular)
axis equal
% Turn off the axes so they are not visible
axis off
% Show instructions above square
if (fractionOfCatchTrials>0)
    title('Click inside the black square when the word GO appears in GREEN','fontweight','bold','fontsize',14)
else
    title('Click inside the black square when the word GO appears','fontweight','bold','fontsize',14)
end
% Draw the text READY in white ('w') in the middle of the box
texthandle=text(0.5,0.5,'Click here when ready','fontweight','bold','fontsize',20,'color','w','horizontalalignment','center','verticalalignment','middle');

% Wait for user to click to start experiment
waitforbuttonpress

% Initialize the trial counter variable to 0
n=0;
% Initialize the number of errors (false alarms) to 0
nErrors=0;
nErrTrials=0;
% Repeat the steps between 'while' and 'end' below until we have measured 10 reaction times
while n<10
    % Start each trial by displaying READY in white ('w')
    set(texthandle,'string','READY','color','w')
    % Wait for random interval 1-2s
    pause(rand+1);
    % Get a random number between 0 and 1
    aRandomNumber=rand;
    if (aRandomNumber>fractionOfCatchTrials)
        % Correct response trial (user should click)
        % Draw the text GO in green ('g') in the middle of the box
        set(texthandle,'string','GO','color','g')
        % Start the clock
        tic
        % Wait for mouse click
        waitforbuttonpress
        % Increment the trial counter variable
        n=n+1;
        % Record time elapsed until mouse click
        rt(n)=toc;
        % Give visual feedback
        set(texthandle,'string','OK!','color','g')
        % Force drawing to happen immediately
        drawnow
        % Play a happy sound
        sound(sin(linspace(0,200,500)),8192)
        % Wait for .5 seconds
        pause(0.5)
    else
        nErrTrials=nErrTrials+1;
        % Catch trial (user should not click)
        % Draw the text GO in red ('r') in the middle of the box
        set(texthandle,'string','GO','color','r')
        % Set a function to call if the user presses a button (false alarm)
        if (isempty(strfind(license,'GNU')))
            set(gcf,'WindowButtonDownFcn',@falsealarm) % this only works in Matlab
        else
            set(gcf,'WindowButtonDownFcn','falsealarmoctave')
        end
        % Wait for 1 second
        pause(1)
        % Clear the function set above
        set(gcf,'WindowButtonDownFcn',[])
    end
end

% We have now collected all reaction times, so just need to wrap up
% Display a message to indicate it's finished
set(texthandle,'string',sprintf('Well done %s!',subject),'color','b')
% Force drawing to happen immediately
drawnow
if (isempty(strfind(license,'GNU')))
    % If we're on Matlab, load some music to play
    load handel
    % Select the first 20000 time points (about 2.4 seconds)
    yy=y(1:20000);
    % Multiply the sound with a sine wave so intensity increases, then goes down again
    yy=yy.*sin(linspace(0,pi,length(yy)))';
    % Play the music
    sound(yy,Fs)
end
% Close the figure
close
% Return to where the function was called from
propErrors=nErrors/nErrTrials;

return



% This function sets the text to FALSE ALARM and is called when the user clicks on a catch trial
function falsealarm(src,eventdata)
global texthandle nErrors
set(texthandle,'string','FALSE ALARM!!')
drawnow
sound(tan(linspace(0,30,1000)),8192)
% Increase the number of errors by 1
nErrors=nErrors+1;

% This function sets the text to FALSE ALARM and is called when the user clicks on a catch trial
function falsealarmoctave
global texthandle nErrors
set(texthandle,'string','FALSE ALARM!!')
drawnow
sound(tan(linspace(0,30,1000)),8192)
% Increase the number of errors by 1
nErrors=nErrors+1;
