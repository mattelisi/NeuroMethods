function[rects] = detPathRects(path,width)
%
% determine path rects on the basis of texture size "width"
%

rects = zeros(size(path,1),4);
rects = [path-width, path+width];