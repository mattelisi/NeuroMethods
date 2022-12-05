% FFT example

close all;
clear all;

n_cycles = 2;
L =  (28 * 24) * n_cycles;
t = linspace(0, 28*n_cycles, L);
bodytemp = 36.8 + 0.2*cos((2*pi*(t-16))/28) + 0.3*cos(2*pi*(t-14/24));

% add noise to make things interesting
bodytemp = bodytemp + randn(1, L)*0.2;

% figure
figure;
set(gcf,'pos',[50 50 1050 1050],'color','white');
subplot(2,1,1);
plot(t, bodytemp,'linewidth',1, 'color','blue');
xlabel("time [days]");
ylabel("temperature");

% compute FFT
Y = fft(bodytemp);

Fs = 24;  % Sampling frequency (24 measurements per day) 


P2 = abs(Y/L); % Compute the normalized two-sided spectrum P2
P1 = P2(1:L/2+1); % compute the single-sided spectrum P1
P1(2:end-1) = 2*P1(2:end-1); % (to get single-sided spectrum you need to multiply by 2)
f = Fs*(0:(L/2))/L; % frequency coordinates

subplot(2,1,2);

% note that we remove the 1st component - this is the DC, the average value of the signal
plot(f(2:150),P1(2:150),'linewidth',1, 'color','blue') ;
title("Amplitude Spectrum");
xlabel("f (cycles per day)");
ylabel("|P1(f)|");

%% bonus
% obtain back the original signal with the inverse fourier transform
% remove all high frequencies, recover only monthly trend

% Low-Pass Filter:
%f = Fs*(-(L/2):(L/2 - 1))/L;
%BPF = (abs(f) < 0.5);
%X = ifft(BPF.*Y);

Y = fftshift(fft(bodytemp - mean(bodytemp)));
dF = Fs/L;
f = (-Fs/2:dF:Fs/2-dF);
BPF = abs(f) < 1/24; % this leave only very low frequency components

%BPF = (abs(f) > 0.9  & abs(f) < 1.1); % try also other filters
%BPF = (abs(f) < 1.1);

X = ifft(ifftshift(BPF.*Y));

figure;
set(gcf,'pos',[50 50 1050 1050/2],'color','white');
plot(t, X,'linewidth',1, 'color','blue');
title("Signal reconstructed after filtering")
xlabel("time [days]");
ylabel("temperature change");

