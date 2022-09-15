
[x,y]  = bezierCurve2(0,0,100,100,1000);
plot(x,y) 
axis([-50 150 -50 150])

hold on
for i = 1:20
    [x,y]  = bezierCurve2(0,0,100,100,1000);
    plot(x,y)
    
end
hold off



[x2,y2]  = bezierCurve2(600,600,30,900,1000);
[x,y]  = bezierCurve(600,600,30,900,1000);

plot(x,y)
hold on
plot(x2,y2)
hold off

scatter(x, x2)
