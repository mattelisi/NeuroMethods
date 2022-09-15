function[noiseimg] = generateNoiseImage(design,nFrames,visual,td, fd)
%
% fd = vertical refresh duration in seconds
%
stepf = round(visual.ppd*(design.drifting_speed*fd));
noiseimg = (255 * fractionalNoise(zeros(visual.tarSize*2+stepf*nFrames, visual.tarSize), td.tarFreq, design.octaves))  - visual.bgColor;
