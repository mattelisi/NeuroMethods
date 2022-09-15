function [SJ] = getSJinfo
% query and collect sj info
FlushEvents('keyDown');
SJ.number = input('\n\n Subject number (set 0 to test without storing data):  ');
if SJ.number >0 %~= 0
    fprintf('\n\n   Please type the following informations\n');
    SJ.id =  input('        initials / identifier:  ','s');
    SJ.age =   input('        age:  ');
    SJ.gend =   input('        gender (m/f):  ','s');
end