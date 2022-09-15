function [taskInfo] = getTaskInfo
%
% asks for task-specific info
%

FlushEvents('keyDown');

nses = input('\n\n>>>> How many sessions?:  ','s');

if length(nses)==1
    nses = strcat('0',nses);
end

taskInfo = sprintf('%s',nses);

