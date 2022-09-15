function[m] = framesIllusion(design, visual, td, nFrames, noiseimg, fd)

% here we prepare one set texture with drifting internal motion (2D noise)
% - this version works with the perceptual task left/right tilt -

stepf = round(visual.ppd*(design.drifting_speed*fd));
reversal = nFrames/2;

% gaussian envelope
imWidth = floor(visual.tarSize/2);
[gx,gy]=meshgrid(-imWidth:imWidth, -imWidth:imWidth);
env = exp( -((gx.^2)+(gy.^2)) /(2*(td.sigma)^2));

segBeg = 1;
segEnd = visual.tarSize;
segBeg2 = 1 + stepf*reversal;
segEnd2 = visual.tarSize + stepf*reversal;

% compute textures for individual frames
m = zeros(visual.tarSize, visual.tarSize, nFrames);
cf = 0; cb = 0; fi = 0;
for i=1:nFrames
    if i<=reversal
        aBeg = segBeg + (cf*stepf);
        aEnd = segEnd + (cf*stepf);
        cf = cf+1;
    else
        aBeg = segBeg2 - (cb*stepf);
        aEnd = segEnd2 - (cb*stepf);
        cb = cb+1;
    end
    fi = fi + 1;
    noisePatt = noiseimg(aBeg:aEnd,:);
    m(:,:,fi) = uint8(visual.bgColor + noisePatt.*env);
end
