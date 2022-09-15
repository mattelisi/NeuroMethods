function movingDots(scr,dots,duration, visual, decision)
% Animates a field of moving dots based on parameters defined in the 'dots'
% structure over a period of seconds defined by 'duration'.
%
% The 'dots' structure must have the following parameters:
%
%   nDots            Number of dots in the field
%   speed            Speed of the dots (degrees/second)
%   direction        Direction 0-360 clockwise from upward
%   lifetime         Number of frames for each dot to live
%   apertureSize     [x,y] size of elliptical aperture (degrees)
%   center           [x,y] Center of the aperture (degrees)
%   color            Color of the dot field [r,g,b] from 0-255
%   size             Size of the dots (in pixels)
%   coherence        Coherence from 0 (incoherent) to 1 (coherent)
%
% 'dots' can be an array of structures so that multiple fields of dots can
% be shown at the same time.  The order that the dots are drawn is
% scrambled across fields so that one field won't occlude another.
%
% mod. Matteo Lisi 2019

%Calculate total number of dots across fields
nDots = sum([dots.nDots]);

%Zero out the color and size vectors
colors = zeros(3,nDots);
sizes = zeros(1,nDots);

% 'Shuffle' black and white colors
for i=1:length(dots)
    dots(i).color = dots(i).color(randperm(nDots),:);
end

%Generate a random order to draw the dots so that one field won't occlude
%another field.
order=  randperm(nDots);

%% Intitialize the dot positions and define some other initial parameters
count = 1;
for i=1:length(dots) %Loop through the fields
    
    %Calculate the left, right top and bottom of each aperture (in degrees)
    l(i) = dots(i).center(1)-dots(i).apertureSize(1)/2;
    r(i) = dots(i).center(1)+dots(i).apertureSize(1)/2;
    b(i) = dots(i).center(2)-dots(i).apertureSize(2)/2;
    t(i) = dots(i).center(2)+dots(i).apertureSize(2)/2;
    
    %Generate random starting positions
    dots(i).x = (rand(1,dots(i).nDots)-.5)*dots(i).apertureSize(1) + dots(i).center(1);
    dots(i).y = (rand(1,dots(i).nDots)-.5)*dots(i).apertureSize(2) + dots(i).center(2);
    
    %Create a direction vector for a given coherence level
    direction = rand(1,dots(i).nDots)*360;
    nCoherent = ceil(dots(i).coherence*dots(i).nDots);  %Start w/ all random directions
    direction(1:nCoherent) = dots(i).direction;  %Set the 'coherent' directions
    
    %Calculate dx and dy vectors in real-world coordinates
    dots(i).dx = dots(i).speed*sin(direction*pi/180) * scr.fd;
    dots(i).dy = -dots(i).speed*cos(direction*pi/180) * scr.fd;
    dots(i).life = ceil(rand(1,dots(i).nDots)*dots(i).lifetime);
    
    %Fill in the 'colors' and 'sizes' vectors for this field
    id = count:(count+dots(i).nDots-1);  %index into the nDots length vector for this field
    %colors(:,order(id)) = repmat(dots(i).color(:),1,dots(i).nDots);
    colors(:,order(id)) = dots(i).color';
    sizes(order(id)) = repmat(dots(i).size,1,dots(i).nDots);
    count = count+dots(i).nDots;
end

%Zero out the screen position vectors and the 'goodDots' vector
pixpos.x = zeros(1,nDots);
pixpos.y = zeros(1,nDots);
%goodDots = false(zeros(1,nDots));
goodDots = zeros(1,nDots);

%Calculate total number of temporal frames
nFrames = round(duration/scr.fd);

%% Loop through the frames
tFlip = GetSecs;
for frameNum=1:nFrames
    count = 1;
    for i=1:length(dots)  %Loop through the fields
        
        % debug
        %fprintf(1, sprintf('\ndots.x and .dx size: %i %i and %i %i\n',size(dots(i).x),size(dots(i).dx)));
        %fprintf(1, sprintf('\ndots.y and .dx size: %i %i and %i %i\n',size(dots(i).y),size(dots(i).dy)));
        
        %Update the dot position's real-world coordinates
        dots(i).x = dots(i).x + dots(i).dx;
        dots(i).y = dots(i).y + dots(i).dy;
        
        %Move the dots that are outside the aperture back one aperture width.
        dots(i).x(dots(i).x<l(i)) = dots(i).x(dots(i).x<l(i)) + dots(i).apertureSize(1);
        dots(i).x(dots(i).x>r(i)) = dots(i).x(dots(i).x>r(i)) - dots(i).apertureSize(1);
        dots(i).y(dots(i).y<b(i)) = dots(i).y(dots(i).y<b(i)) + dots(i).apertureSize(2);
        dots(i).y(dots(i).y>t(i)) = dots(i).y(dots(i).y>t(i)) - dots(i).apertureSize(2);
        
        %Increment the 'life' of each dot
        dots(i).life = dots(i).life+1;
        
        %Find the 'dead' dots
        deadDots = mod(dots(i).life,dots(i).lifetime)==0;
        
        %Replace the positions of the dead dots to random locations
        dots(i).x(deadDots) = (rand(1,sum(deadDots))-.5)*dots(i).apertureSize(1) + dots(i).center(1);
        dots(i).y(deadDots) = (rand(1,sum(deadDots))-.5)*dots(i).apertureSize(2) + dots(i).center(2);
        
        %Calculate the index for this field's dots into the whole list of
        %dots.  Using the vector 'order' means that, for example, the first
        %field is represented not in the first n values, but rather is
        %distributed throughout the whole list.
        id = order(count:(count+dots(i).nDots-1));
        
        %Calculate the screen positions for this field from the real-world coordinates
        %pixpos.x(id) = angle2pix(display,dots(i).x)+ display.resolution(1)/2;
        %pixpos.y(id) = angle2pix(display,dots(i).y)+ display.resolution(2)/2;
        pixpos.x(id) = round(dots(i).x);
        pixpos.y(id) = round(dots(i).y);
        
        %Determine which of the dots in this field are outside this field's
        %elliptical aperture
        goodDots(id) = (dots(i).x-dots(i).center(1)).^2/(dots(i).apertureSize(1)/2)^2 + ...
            (dots(i).y-dots(i).center(2)).^2/(dots(i).apertureSize(2)/2)^2 < 1;
        count = count+dots(i).nDots;
    end
    
    %Draw all fields at once
    Screen('DrawDots',scr.main,[pixpos.x(logical(goodDots));pixpos.y(logical(goodDots))], sizes(logical(goodDots)), colors(:,logical(goodDots)),[0,0],1);
    
    %% additional (task specific) drawing    
    draw_placeholders(decision, scr, visual);
    
%     Screen(scr.main,'FillOval',visual.darkGrey , visual.target_location_up+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
%     DrawFormattedText(scr.main, decision, 'center', round(scr.centerY-textureWidth/1.5), visual.white);
%     %Screen(scr.main,'FrameOval',150,linesRect,1);
%     if strcmp(decision,'2')
%         Screen('FillOval',scr.main,visual.red,target_location_left+round([-targetSize -targetSize targetSize targetSize]/2));
%         Screen('FillOval',scr.main,visual.green,target_location_right+round([-targetSize -targetSize targetSize targetSize]/2));
%     else
%         Screen(scr.main,'FillOval',visual.white,target_location_left+round([-targetSize -targetSize targetSize targetSize]/2));
%         Screen(scr.main,'FillOval',visual.white,target_location_right+round([-targetSize -targetSize targetSize targetSize]/2));
%     end
    
    %% Flip
    tFlip = Screen('Flip', scr.main, tFlip+scr.fd);
    
end
end