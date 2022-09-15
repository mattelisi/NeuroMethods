function [td, tarfra] = compMotionPar (td,scr,design)

% compute motion parameters for a given trial

% envelope motion
td.period = (td.trajLength*2) / td.env_speed;       % sec
timeIndex = linspace(0, 1, round(td.period/scr.fd));
switch design.motionType
    case 'triangular'
        tarRad = td.initPos * (td.trajLength/2) * sawtooth(2*pi*timeIndex, 0.5);  % target radius for each frame
    case 'sinusoidal'
        tarRad = td.initPos * (td.trajLength/2) * sin(2*pi*(timeIndex+0.25));
end
tarRad(end) = [];
tarAng = repmat(deg2rad(90 + td.alpha), 1, length(tarRad));

[x, y] = pol2cart(tarAng, tarRad);  % x-y coord. of the envelope for each frame
td.tarPos = [x' -y'];

% number of frames for a single cycle
tarfra = length(tarRad);
