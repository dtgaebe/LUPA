clear; clc; close all


%% ------------MultiSine-------------------------------
fmin = 0.05; % min frequency for multisine
fmax = 2; % max frequency for multisine
fs = 1000;
rLen = 300;  %% length of created signal (s) for multisine
nRepeats = 4; % times signal is repeated
nExp = 3; % number of phase realizations
NumPhases = 2000;
fmins = [0.05 0.635 1.335];
fmaxs = [0.765 1.465 2];
msnames = {'MS1','MS2','MS3'};

% sig = genMultiSine_NInput(fmin,fmax,rLen,'numPhases',NumPhases,'plotFlag',1,'dt',1/fs,'NumExp',3,'NumRepeat',nRepeats)
for i = 1:3
sigOld = genMultiSine_NInput(fmins(i),fmaxs(i),rLen,'numPhases',NumPhases,'plotFlag',1,'dt',1/fs,'NumExp',3,'NumRepeat',nRepeats);
sig.(msnames{i}) = sigOld.(msnames{i});
end
%sig = whiteNoiseGen(fs,fmin,fmax,rLen,nRepeats);

%% ------------Chirp-----------------------------------
f0 = 1/20;
f1 = 1/1;
fs = 1000;
initLength = 10;
numseconds = 300;
t = 0:1/fs:numseconds-1/fs;
t1 = numseconds;
chirp = chirp(t,f0,t1,f1);
r = 40/numseconds;
r_win = tukeywin(length(t),r)';
chirp = chirp .* r_win;
chirp = [zeros(1,fs*initLength) chirp];
t = 1/fs:1/fs:length(chirp)/fs;
sig.Chirp = timeseries(chirp,t);
plot(sig.Chirp)

%% ---------------Ramps---------------------------------
freq = 0.02; % 1/repeat time of single ramp
amp = 1;    % max amplitude of ramp and sine wave (will be scaled in simulink)
fs = 1000; % sampling frequency of ramp signal

ramp = zeros(6*fs*1/freq,1);

t=[1/fs:1/fs:(1/fs)*length(ramp)];

ramp(fs/(2*freq):fs/freq-1) = linspace(0,amp,(fs/freq-fs/(2*freq)));
ramp(3*fs/(2*freq):2*fs/freq-1) = linspace(0,-amp,(fs/freq-fs/(2*freq)));
ramp(5*fs/(2*freq):3*fs/freq-1) = linspace(0,amp,(fs/freq-fs/(2*freq)));
ramp(7*fs/(2*freq):4*fs/freq-1) = linspace(0,-amp,(fs/freq-fs/(2*freq)));

% ramp(fs/(2*freq):fs/freq-1) = linspace(0,amp,(fs/freq-fs/(2*freq)));
% ramp(4*fs/(2*freq):2.5*fs/freq-1) = linspace(0,-amp,(fs/freq-fs/(2*freq)));
% ramp(7*fs/(2*freq):4*fs/freq-1) = linspace(0,amp,(fs/freq-fs/(2*freq)));
% ramp(10*fs/(2*freq):5.5*fs/freq-1) = linspace(0,-amp,(fs/freq-fs/(2*freq)));


sig.Ramp = timeseries(ramp,t);

%% ---------------Sine---------------------------------
period = 3; % period for sine wave
sineDuration = 50;
initLength = 10;
t = 1/fs:1/fs:sineDuration;
sine = amp .* sin(2*pi./period*t);
sine = [zeros(1,fs*initLength) sine];
t = 1/fs:1/fs:length(sine)/fs;
sig.Sine = timeseries(sine,t);



%% ---------------Combine into input signals---------------------
commandSigs = Simulink.SimulationData.Dataset;
commandSigs = commandSigs.addElement(sig.Ramp,'Ramp');
commandSigs = commandSigs.addElement(sig.Sine,'Sine');
% commandSigs = commandSigs.addElement(sig.WN1,'WN1');
% commandSigs = commandSigs.addElement(sig.WN2,'WN2');
% commandSigs = commandSigs.addElement(sig.WN3,'WN3');
commandSigs = commandSigs.addElement(sig.MS1,'MS1');
commandSigs = commandSigs.addElement(sig.MS2,'MS2');
commandSigs = commandSigs.addElement(sig.MS3,'MS3');
commandSigs = commandSigs.addElement(sig.Chirp,'Chirp');
save('C:\2023\Software\LUPA\Simulink\utils\commandSignals','commandSigs')

figure
subplot(311)
plot(sig.Ramp)
xlabel('time (s)')
ylabel('ramp amplitude')

subplot(312)
plot(sig.Sine)
xlabel('time (s)')
ylabel('sine signal')

subplot(313)
plot(sig.MS1)
hold on
plot(sig.MS2)
plot(sig.MS3)
xlabel('time (s)')
ylabel('white noise signal')
legend('MS1','MS2','MS3')
