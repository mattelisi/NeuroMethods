function [pathRects, patchAngle] = recomputeRect (timeIndex,angle,visual,td,cxm,cym)

%switch design.motionType
%    case 'triangular'
%        tarRad = td.initPos * (td.trajLength/2) * sawtooth(2*pi*timeIndex, 0.5);  % target radius for each frame
%    case 'sinusoidal'
%        tarRad = td.initPos * (td.trajLength/2) * sin(2*pi*(timeIndex+0.25));
%end

tarRad = td.initPos * (td.trajLength/2) * sawtooth(2*pi*timeIndex, 0.5);
tarAng = repmat(deg2rad(angle), 1, length(tarRad));
[x, y] = pol2cart(tarAng, tarRad);  % x-y coord. of the envelope for each frame
td.tarPos = [x' -y'];
pathRects = detRect(visual.ppd*td.tarPos(:,1) + cxm + visual.ppd*td.ecc, visual.ppd*td.tarPos(:,2) + cym, visual.tarSize);

% set angle for drawing textures
if td.cond<0
    %patchAngle =  90 -(angle -90);
    patchAngle =  -angle;
else
    %patchAngle = -90 -(angle - 90);
    patchAngle = -180 -angle;
end
if td.initPos==-1; patchAngle = 180+patchAngle; end