% Clear all variables from memory
clear all

% Set path so commands in octave subdirectory are available
%addpath(genpath(pwd))

% This section collects reaction time data - leave this for last

% Get users to input number and names of players
nPlayers=2;
for n=1:nPlayers
    t=inputdlg(sprintf('Name of player %i:',n),'Enter name');
    if (isempty(t))
        disp('Script stopped by user')
        return
    end
    player{n}=t{1};
end

% For each player, collect reaction times
for n=1:nPlayers
    % Give player instructions
    msgbox(sprintf('Player %i (%s) get ready',n,player{n}));
    msgbox('Click on the black square when the word GO appears');
    % First experiment: no catch trials
    catchtrialfraction=0;
    % Call function that performs actual experiment
    [RTnc,nErrnc]=measureReactionTimes(player{n},catchtrialfraction);

    % Give player instructions
    msgbox(sprintf('Player %i (%s) get ready',n,player{n}));
    msgbox('Now click on the black square ONLY when the word GO appears in GREEN');
    % Second experiment: 50% catch trials
    catchtrialfraction=0.5;    
    % Call function that performs actual experiment
    [RTc,nErrc]=measureReactionTimes(player{n},catchtrialfraction);
    % Save reaction times to the right player
    if (n==1)
        RTnc1=RTnc;
        RTc1=RTc;
        nErrc1=nErrc;
    elseif (n==2)
        RTnc2=RTnc;
        RTc2=RTc;
        nErrc2=nErrc;
    end
end

% This section computes descriptive and inferential statistics (t-test)
% Compute mean and standard deviation for each player
% meanRTnc1 is the mean RT for the non-catch trials for player 1
meanRTnc1=mean(RTnc1);
% stdRTnc1 is the standard deviation of the RT for the non-catch trials for player 1
stdRTnc1=std(RTnc1);
% meanRTc1 is the mean RT for the catch trials for player 1
meanRTc1=mean(RTc1);
% stdRTc1 is the standard deviation of the RT for the catch trials for player 1
stdRTc1=std(RTc1);

meanRTnc2=mean(RTnc2);
stdRTnc2=std(RTnc2);
meanRTc2=mean(RTc2);
stdRTc2=std(RTc2);

% Compare reaction times between conditions using two-sample t-tests
if (isempty(strfind(license,'GNU')))
    % If on Matlab
    % Pcond1 is the P-value of the difference between mean RTs for conditions 1 and 2 being due to chance alone for player 1 (testing hypothesis that no-catch trials are faster)
    [Hcond1,Pcond1]=ttest2(RTnc1,RTc1,'tail','left');

    % Pcond2 is the P-value of the difference between mean RTs for conditions 1 and 2 being due to chance alone for player 2 (testing hypothesis that no-catch trials are faster)
    [Hcond2,Pcond2]=ttest2(RTnc2,RTc2,'tail','left');
    
    % Compare reaction times between players using two-sample t-tests
    % Psubj12nc is the P-value of the difference between players 1 and 2 for the no-catch trials
    [Hsubj12nc,Psubj12nc]=ttest2(RTnc1,RTnc2);
    % Psubj12c is the P-value of the difference between players 1 and 2 for the 50% catch trials
    [Hsubj12c,Psubj12c]=ttest2(RTc1,RTc2);
else
    % On Octave
    % Pcond1 is the P-value of the difference between mean RTs for conditions 1 and 2 being due to chance alone for player 1 (testing hypothesis that no-catch trials are faster)
    Pcond1=t_test_2(RTnc1,RTc1,'<');

    Pcond1=t_test_2(RTnc1,RTc1,'<');
    % Pcond2 is the P-value of the difference between mean RTs for conditions 1 and 2 being due to chance alone for player 2 (testing hypothesis that no-catch trials are faster)
    Pcond2=t_test_2(RTnc2,RTc2,'<');
    
    % Compare reaction times between players using two-sample t-tests
    % Psubj12nc is the P-value of the difference between players 1 and 2 for the no-catch trials
    Psubj12nc=t_test_2(RTnc1,RTnc2);
    % Psubj12c is the P-value of the difference between players 1 and 2 for the 50% catch trials
    Psubj12c=t_test_2(RTc1,RTc2);
end

% Call script to plot the results
plotReactionTimesData
