 clear; clc; close all
addpath(genpath('utils/'))
%% === Assign Constants ===================================================
disp('*** Setting model parameters ***')

Ts = 0.001;
CL = 7.64;  % Current limit parameter (Set in EASII)
Kt = 7.86;  % Determined experimentally  % Kt = 8.51;  % From datasheet
Decimation = 1;
Decimation100Hz = 0.01./Ts;

appName = 'LUPACheckoutApp.mlapp';
buildDir = fullfile('C:','SimulinkBuild');
mdlName = 'LUPACheckout';
tgName = 'performance1';

mdlInfo = Simulink.MDLInfo(mdlName);
mdlVersion = mdlInfo.ModelVersion;
% addpath(genpath(pwd))
%% === Open the model =========================================
disp('*** Open Simulink Model ***')
open_system(mdlName);

%% === load input signals =========================================
disp('*** Load Input command signals ***')
load('utils/commandSignals.mat');
period = 1.5; % period for sine wave
commandSigs = modifySine(commandSigs,period);
waveform = commandSigs;
set_param(mdlName,'ExternalInput','waveform');


%% === Load and compile the model =========================================
disp('*** Load and Build Simulink Model ***')
set_param(mdlName,'LoadExternalInput','on');
set_param(mdlName,'StopTime','Inf');
load_system(mdlName)
set_param(mdlName, 'RTWVerbose','off');

%% === set xml file based on sampling frequency============================
selectXMLfile(Ts,mdlName);
% LUPA_eCat_init = strcat('C:\Software\LUPA-Checkout\TwinCAT\LUPACheckout\FilterStudy2\LUPACheckout1kHzF30kHz.xml');
% set_param([mdlName,'/Initialization/EtherCAT Init'],'config_file',LUPA_eCat_init);
%% === Build Model ========================================================
disp('*** Build Simulink RT (Speedgoat) ***')
% tg=slrealtime;
slbuild(mdlName);
% load(tg,mdlName);
%% === Open the app =======================================================

disp('*** Start user app ***')
run(appName)


%% === Functions for readability of code ==================================

function selectXMLfile(Ts,mdlName)

% set the full path to the EtherCAT config files.
current_dir = pwd;
if Ts == 0.0001     % 10kHz
    LUPA_eCat_init = strcat(current_dir,'\etherCAT\LUPACheckout10kHzxml.xml');
elseif Ts == 0.0002 % 5kHz
    LUPA_eCat_init = strcat(current_dir,'\etherCAT\LUPACheckout5kHzxml.xml');
elseif Ts == 0.0004 % 2.5kHz
    LUPA_eCat_init = strcat(current_dir,'\etherCAT\LUPACheckout2_5kHzxml.xml');
elseif Ts == 0.0005 % 2kHz
    LUPA_eCat_init = strcat(current_dir,'\etherCAT\LUPACheckout2kHzxml.xml');
else
    LUPA_eCat_init = strcat(current_dir,'\etherCAT\LUPACheckout1kHzxml.xml');
end

set_param([mdlName,'/Initialization/EtherCAT Init'],'config_file',LUPA_eCat_init);

end

function commandSigs = modifySine(commandSigs,period)

sineDuration = 180;
initLength = 10;
fs = 1000;
amp = 1;  % Leave this at 1 and change in App
t = 1/fs:1/fs:sineDuration;
sine = amp .* sin(2*pi./period*t);
sine = [zeros(1,fs*initLength) sine];
t = 1/fs:1/fs:length(sine)/fs;
sig.Sine = timeseries(sine,t);
commandSigs = commandSigs.setElement(2,sig.Sine,'Sine');
end