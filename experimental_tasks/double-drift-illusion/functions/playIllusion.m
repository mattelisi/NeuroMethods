function playIllusion( path , condition )
%%PLAYILLUSION( path , condition )
%
% SYNTAX
% playillusion( path , condition )
%
% INPUT
% 1. path of the pnoise patches : path = '' , 'inout' , 'rotate' , 'global'
% 2. definition of the noise patches : condition = '' , 'stimulus' , 'control'
%
% NOTES
% If not found in the current folder, the function will generate m_2D.mat
% or m_3D.mat that contains the stimulus (2D) noise patches or the control
% (3D) noise patches.


%% Check input arguments

% Number of input arguments
assert( nargin == 2 , '%s requires two arguments : path , condition',mfilename )

% Path
assert( ischar( path ) , 'path must be a string' )
switch lower(path)
    case ''
    case 'inout'
    case 'rotate'
    case 'global'
    otherwise
        error('unknown path')
end
path = lower(path);

% Get directory content
content = dir;
save_patches = 0;

% Condition
assert( ischar( condition ) , 'condition must be a string' )
switch lower(condition)
    case ''
        if ~any(strcmp({content.name},'m_2D.mat'))
            save_patches = 1;
        end
    case 'stimulus'
        if ~any(strcmp({content.name},'m_2D.mat'))
            save_patches = 1;
        end
    case 'control'
        if ~any(strcmp({content.name},'m_3D.mat'))
            save_patches = 1;
        end
    otherwise
        error('unknown condition')
end
condition = lower(condition);

%% Load stimulation parameters

setParameters;

% No path ?
if strcmp( path , '' )
    stim.pathLength = 0;
end

Common.SetAngles;


%% Start PTB window

prepareScreen;


%% Convert everything in pixels

Common.ConvertInPix;


%% Generate and store noise images, if needed

if save_patches
    
    switch condition
            
        
        
        case 'stimulus'
            
            noiseArray = generateNoiseImage(stim,visual, scr.fd);
            for ti = 1:16 % for each of the 16 noise patches
                noiseArray = cat(3, noiseArray, generateNoiseImage(stim,visual,scr.fd));
            end
            
            m_2D = cell(16,1);
            
        case 'control'
            
            noiseArray = generateNoiseVolume(stim,visual, scr.fd);
            for ti = 1:16
                noiseArray = cat(4, noiseArray, generateNoiseVolume(stim,visual,scr.fd));
            end

            
            m_3D = cell(16,1);
            
    end
    
    
else
    
    switch condition
        
        case ''
            load('m_2D.mat')
            
        case 'stimulus'
            load('m_2D.mat')
            
        case 'control'
            load('m_3D.mat')
            
    end
    
end


%% Cut out and stores individual frames; save them as openGL textures
nFrames = round(stim.period/scr.fd);
motionTex = zeros(16, nFrames);

for ti = 1:16 % for each patch
    
    if save_patches
        
        switch condition
            
                
            case 'stimulus'
                
                m = framesIllusion(stim, visual, noiseArray(:,:,ti), scr.fd);
                m_2D{ti} = uint8(m);
                
                for i=1:nFrames % for each frame
                    motionTex(ti,i)=Screen('MakeTexture', scr.main, m(:,:,i));
                end
                
                save('m_2D','m_2D');
                
            case 'control'
                
                m = framesControl(stim, visual, noiseArray(:,:,:,ti), scr.fd);
                m_3D{ti} = uint8(m);
                
                for i=1:nFrames % for each frame
                    motionTex(ti,i)=Screen('MakeTexture', scr.main, m(:,:,i));
                end
                
                save('m_3D','m_3D');
                
        end
        
    else
        
        switch condition
            
            case ''
                m_2D{ti}( : , : , : ) = 255;
                for i=1:nFrames % for each frame
                    motionTex(ti,i)=Screen('MakeTexture', scr.main, m_2D{ti}(:,:,i));
                end
                
            case 'stimulus'
                for i=1:nFrames % for each frame
                    motionTex(ti,i)=Screen('MakeTexture', scr.main, m_2D{ti}(:,:,i));
                end
                
            case 'control'
                for i=1:nFrames % for each frame
                    motionTex(ti,i)=Screen('MakeTexture', scr.main, m_3D{ti}(:,:,i));
                end
                
        end
        
    end
    
end


if save_patches
    
    switch condition
        
        case 'stimulus'
            save('m_2D','m_2D');
            
        case 'control'
            save('m_3D','m_3D');
            
    end
    
end

% Shuffle texture : counterbalance
motionTex = motionTex(Shuffle(1:16),:);


%% Compute path coordinates

rectAll = coordIllusion(stim, visual, scr); % basic value

switch condition
    
    case ''
        
    case 'stimulus'
        
    case 'control'
        
        switch path
            
            case ''
                
            case 'inout'
                rectAll = coordInOut(stim, visual, scr);
                
            case 'rotate'
                rectAll = coordRotation(stim, visual, scr);
                
            case 'global'
                
        end
        
end

%% Set sequence index (motion start at trajectory midpoint)

Common.SetSequenceIndex;


%% Internal motion angles values
% Determine the quality of the illusion, rotation vs expanding-contracting
% (inout)

angles = angles_other; %  basic value

switch condition
    case ''
        
    case 'stimulus'
        
        switch path
            case ''
                angles = angles_expanding;
                
            case 'inout'
                angles = angles_expanding;
                
            case 'rotate'
                angles = angles_rotating;
                
            case 'global'
                
        end
        
    case 'control'
        
end


%% Display stimulus

showStim = 1;

while showStim
    for cycle = 1:nCycles
        if cycle == tarPos % this determine whether there is path shortening
            as = seq_tar;
        else
            as = seq;
        end
        for i = as
            Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
            drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
            Screen('Flip', scr.main);
            [keyIsDown] = KbCheck(-1);
            if keyIsDown
                showStim=0;
                break;
            end
        end
    end
end


%% END

END;


end
