function[noiseimg] = generateNoiseVolume(design,nFrames,visual,td, fd)
%
% task noise & adjustments
%

stepf = round(visual.ppd*(design.control_speed*fd));
noiseimg = 255 * fractionalNoise3(zeros(visual.tarSize, visual.tarSize, nFrames+2), td.tarFreq, design.octaves, stepf) - visual.bgColor;