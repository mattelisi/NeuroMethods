% This section plots the results
% Close any figures
close all

% Open a figure window
figure
% Plot data into 6 small subplots (2 rows x 3 columns)
% Select first subplot (top row, first column): bar plot with mean RT for each condition for player 1
subplot(2,3,1)
% Plot the mean RT for each condition (catch and non-catch trials) as red bars
bar([meanRTnc1 meanRTc1],'r')
% Label the bars
set(gca,'xticklabel',{'0%','50%'})
% Set a label for the X axis
xlabel('Proportion catch trials')
% Set a label for the Y axis
ylabel('Mean RT (seconds)')    
% Put a title above the plot
title(['Mean RT for player P1 (' player{1} ')'])
% This command keeps whatever is in the plot so we can draw more things without erasing the plot
hold on
% Add error bars in black to plot with no connecting line
h=errorbar([meanRTnc1 meanRTc1],[stdRTnc1 stdRTc1],'k');
set(h,'linestyle','none')
% If the no-catch trials are significantly (P<0.05) faster, put an asterisk above the bar to indicate this
alpha=0.05;
if (Pcond1<alpha)
    text(1,meanRTnc1+stdRTnc1+0.1,'*')
end
% Set the y axis limits so that asterisk and errorbars are visible
set(gca,'ylim',[0 max([meanRTnc1+stdRTnc1 meanRTc1+stdRTc1])+0.5])

% Select second subplot (top row, middle column): bar plot with mean RT for each condition for player 2
subplot(2,3,2)
% Plot the mean RT for each condition (catch and non-catch trials) as blue bars
bar([meanRTnc2 meanRTc2],'b')
% Label the bars
set(gca,'xticklabel',{'0%','50%'})
% Set a label for the X axis
xlabel('Proportion catch trials')
% Set a label for the Y axis
ylabel('Mean RT (seconds)')    
% Put a title above the plot
title(['Mean RT for player P2 (' player{2} ')'])
% This command keeps whatever is in the plot so we can draw more things without erasing the plot
hold on
% Add error bars in black to plot with no connecting line
h=errorbar([meanRTnc2 meanRTc2],[stdRTnc2 stdRTc2],'k');
set(h,'linestyle','none')
% If the no-catch trials are significantly faster, put an asterisk above the bar to indicate this
if (Pcond2<alpha)
    text(1,meanRTnc2+stdRTnc2+0.1,'*')
end
% Set the y axis limits so that asterisk and errorbars are visible
set(gca,'ylim',[0 max([meanRTnc2+stdRTnc2 meanRTc2+stdRTc2])+0.5])

% Bottom row 
% FouRTh plot (second row, first column): plot all players' data together 
subplot(2,3,4)
% Put all mean RTs into a matrix where the rows are the two conditions, and the columns the 2 or 3 players
meanRTall=[meanRTnc1 meanRTnc2; meanRTc1 meanRTc2];
bar(meanRTall)
% Label the bars
set(gca,'xticklabel',{'0%','50%'})
% Set a label for the X axis
xlabel('Proportion catch trials')
% Set a label for the Y axis
ylabel('Mean RT (seconds)')    
% Add a legend
if (nPlayers>1)
    legend({'P1','P2'})
else
    legend({'P1'})
end

% Fifth plot (second row, middle column): % Plot RTs by trial
subplot(2,3,5)
% Put all RTs (not the mean RTs) into one matrix, in which each row is one subject and condition and each column is a trial
% RTall is the RTs for all catch and non-catch trials
RTall=[RTnc1;RTnc2;RTc1;RTc2];

% Exchange rows and columns so that each row is a trial and each column is a subject
% This is called "transposing" the matrix and is done by adding a ' after the variable name:
RTall=RTall';

% Plot RTs against trial number
trialNumber=1:10;
% plot function assigns default colours to lines, but we will specify a marker symbol 's' (square)
plot(trialNumber,RTall,'s-');
% Add a legend - the order must match the order we defined RTall above
legend({'P1 0%','P2 0%','P1 50%','P2 50%'})

xlabel('Trial number')
ylabel('RT (seconds)')
title('RT vs trial number')

% Sixth plot (bottom row, rightmost column): plot number of errors on catch trial
subplot(2,3,6)
bar([nErrc1 nErrc2])
set(gca,'xticklabel',{'P1','P2'})

xlabel('Player')
ylabel('Proportion errors')
title('Proportion of errors by subject on catch trials')


