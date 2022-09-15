function[x,y] = bezierCurve(startX,startY,endX,endY,n)
% bezier curve for coin motion

x = zeros(1,n); y = zeros(1,n);

%if(randn>0)
    
    bezierX= sign(randn)*rand*(startX-endX)/1.5;
    bezierY= sign(randn)*rand*(startY-endY)/1.5;
    t=linspace(0,1,n);
    for i=1:length(t)
        x(i) = (1-t(i))*(1-t(i))*startX + 2*(1-t(i))*t(i)*bezierX+t(i)*t(i)*endX;
        y(i) = (1-t(i))*(1-t(i))*startY + 2*(1-t(i))*t(i)*bezierY+t(i)*t(i)*endY;
    end
    
% else
%     
%     middleX = mean([startX, endX]);
%     middleY = mean([startY, endY]);
%     bezierX1=sign(randn)*rand*(startX-middleX)/8;
%     bezierY1=sign(randn)*rand*(startY-middleY)/8;
%     bezierX2=sign(randn)*rand*(middleX-endX)/8;
%     bezierY2=sign(randn)*rand*(middleY-endY)/8;
%     t=linspace(0,1,round(n/2));
%     for i=1:length(t)
%         x(i) = (1-t(i))*(1-t(i))*startX + 2*(1-t(i))*t(i)*bezierX1+t(i)*t(i)*middleX;
%         y(i) = (1-t(i))*(1-t(i))*startY + 2*(1-t(i))*t(i)*bezierY1+t(i)*t(i)*middleY;
%     end
%     
%     for i=1:length(t)
%         x(length(t)+i) = (1-t(i))*(1-t(i))*middleX + 2*(1-t(i))*t(i)*bezierX2+t(i)*t(i)*endX;
%         y(length(t)+i) = (1-t(i))*(1-t(i))*middleY + 2*(1-t(i))*t(i)*bezierY2+t(i)*t(i)*endY;
%     end
%     
% end