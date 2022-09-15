function [vpcode] = getVpCode
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

sess = input('\n>>>> Enter session number (start from this if more than one session):  ','s');
if length(sess)==1
    sess = strcat('0',sess);
end

if isempty(vpnr)
    vpcode = 'RMItest';
else
    vpcode = sprintf('%s%s%s',nbr,vpnr,sess);
end
