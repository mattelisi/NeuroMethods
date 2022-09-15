function[texture , sdTilt, meanTilt] = makeNoisyLinesTex(win, visual, mu, sigma ,n ,lineLength, lineWidth, textureWidth)
% make texture of oriented lines as in Landy et al (2007)
% Matteo Lisi, LPP 2015

% empty texture colored according to background color in visual
im1 = ones(textureWidth,textureWidth) .* visual.bgColor;
texture = Screen('MakeTexture', win, im1);

% compute lines coordinates
radii = floor(((textureWidth)/2-lineLength/2) .* rand(n,1));
rho = (2*pi) .* rand(n,1);
line_tilt = mu + sigma.*randn(n,1);
line_start_x = radii.*cos(rho) + (lineLength/2).*cos(line_tilt +pi);
line_start_y = -radii.*sin(rho) - (lineLength/2).*sin(line_tilt +pi);
line_end_x = radii.*cos(rho) + (lineLength/2).*cos(line_tilt);
line_end_y = -radii.*sin(rho) - (lineLength/2).*sin(line_tilt);

% prepare coordinate matrix for plotting
XYcoord = zeros(2,n*2);
XYcoord(:,1:2:end) = [line_start_x, line_start_y]';
XYcoord(:,2:2:end) = [line_end_x, line_end_y]';

% set proper anti-aliasing
Screen('BlendFunction', texture, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% make color array
colArray = repelem(repmat([[0,0,0,255]',[255,255,255,255]'],1,n/2),1,2);
  
% draw all lines at once (faster than one at a time) in the texture
Screen('DrawLines', texture, XYcoord, lineWidth, colArray, [textureWidth/2, textureWidth/2], 1);

% store sample averages (in degree)
meanTilt = mean(line_tilt/pi*180);
sdTilt = std(line_tilt/pi*180);
end