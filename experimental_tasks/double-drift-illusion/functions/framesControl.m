function[m] = framesControl(design, visual, td, nFrames, noiseimg, fd)

% here we prepare one set texture with control dynamic noise (3D noise)
% (only one of the 16!)

% if mod(stim.textureSize_px,2) == 0
%     stim.textureSize_px = stim.textureSize_px+1;
% end

%nFrames = round(stim.period/fd);
reversal = nFrames/2;

% gaussian envelope
imWidth = floor(visual.tarSize/2);
[gx,gy]=meshgrid(-imWidth:imWidth, -imWidth:imWidth);
env = exp( -((gx.^2)+(gy.^2)) /(2*(td.sigma)^2));

m = zeros(visual.tarSize, visual.tarSize, nFrames);
c = 3;
for fi=1:nFrames
    if fi>1
        if fi<=reversal
            c = c+1; %step;
        else
            c = c-1; %step;
        end
    end
    noisePatt = noiseimg(:,:,c);
    m(:,:,fi) = uint8(visual.bgColor + noisePatt.*env);
end
