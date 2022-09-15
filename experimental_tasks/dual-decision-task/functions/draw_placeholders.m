function [] = draw_placeholders(decision_order, scr, visual)
% routine to draw placeholder & stuff
%

Screen(scr.main,'FillOval',visual.darkGrey , visual.target_location_up+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/1.8));
DrawFormattedText(scr.main, decision_order, 'center', round(scr.centerY-visual.textureWidth/1.5), visual.white);
% Screen(scr.main,'FrameOval',150,visual.stimRect,1);
switch decision_order
    case '1'
        Screen(scr.main,'FillOval',visual.white, visual.target_location_left+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
        Screen(scr.main,'FillOval',visual.white, visual.target_location_right+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
    case '2'
        Screen(scr.main,'FillOval',visual.red, visual.target_location_left+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
        Screen(scr.main,'FillOval',visual.green, visual.target_location_right+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
    
    case ' '
        Screen(scr.main,'FillOval',visual.white, visual.target_location_left+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
        Screen(scr.main,'FillOval',visual.white, visual.target_location_right+round([-visual.targetSize -visual.targetSize visual.targetSize visual.targetSize]/2));
end