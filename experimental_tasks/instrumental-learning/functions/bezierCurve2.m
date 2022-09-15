function[x,y] = bezierCurve2(startX,startY,endX,endY,n_length)
% generate random Bezier trajectory
% Matteo Lisi, 2019
n_ctrl = 4;
range_x = abs(endX - startX)/2;
range_y = abs(endY - startY)/2;
if startX<endX
    p_x = randomMidpoints(startX - range_x, endX - range_x, n_ctrl-2);
else
    p_x = randomMidpoints(startX + range_x, endX - range_x, n_ctrl-2);
end
if startY<endY
    p_y = randomMidpoints(startY - range_y, endY - range_y, n_ctrl-2);
else
    p_y = randomMidpoints(startY + range_y, endY - range_y, n_ctrl-2);
end

p = [startX, startY; p_x, p_y; endX, endY];
% if startX<endX
%     if startY<endY
%         p = [startX, startY; p_x, p_y; endX, endY];
%     else
%         p = [startX, startY; p_x, p_y; endX, endY];
%     end
% else
%     if startY<endY
%         p = [startX, startY; p_x, p_y; endX, endY];
%     else
%         p = [startX, startY; p_x, p_y; endX, endY];
%     end
% end

n1=n_ctrl-1;
for    i=0:1:n1
    sigma(i+1)=factorial(n1)/(factorial(i)*factorial(n1-i));  % for calculating (x!/(y!(x-y)!)) values 
end
l=[];
UB=[];
for u=linspace(0,1,n_length)
    for d=1:n_ctrl
        UB(d)=sigma(d)*((1-u)^(n_ctrl-d))*(u^(d-1));
    end
    l=cat(1,l,UB);   % catenation 
end
P=l*p;
x = P(:,1);
y = P(:,2);
end

%% extra functions
function[x_i] = randomMidpoints(x0, x1, n)
x_i = x0 + (x1-x0).*rand(n,1);
if x0<x1
    x_i = sort(x_i);
else
    x_i = sort(x_i, 1, 'descend');
end
end

