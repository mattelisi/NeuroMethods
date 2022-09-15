function [vpcode, dual_decision] = getVpCode
%
% asks for subject-ID
% input: exptstr (string) name of experiment
%

FlushEvents('keyDown');

nbr = input('\n\n>>>> Enter subject number:  ','s');

if length(nbr)==1
    nbr = strcat('0',nbr);
end

vpnr = input('\n>>>> Enter subject initials:  ','s');
if length(vpnr)==1
    vpnr = strcat('_',vpnr);
end

sess = input('\n>>>> Enter session number:  ','s');
if length(sess)==1
    sess = strcat('0',sess);
end

while 1
    ddstr = input('\n>>>> Is this a Dual-decision or Control session? (d/c):  ','s');
    if strcmp(ddstr, 'd')
        dual_decision = 1;
        fprintf(1, '\n\t You selected: Dual-Decision (300 trials).\n')
        break;
    elseif strcmp(ddstr, 'c')
        dual_decision = 0;
        fprintf(1, '\n\t You selected: Control (150 trials).\n')
        break;
    else
        fprintf(1, '\n\t ... choose by typing either "d" (for dual-decision condition) or "c" (for control condition) ... \n\n')
    end
end

if isempty(vpnr)
    vpcode = 'test_run';
else
    vpcode = sprintf('%s%s%s',nbr,vpnr,sess);
end