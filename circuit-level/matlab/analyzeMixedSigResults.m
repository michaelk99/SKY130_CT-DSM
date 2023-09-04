% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2023 Michael Koefinger
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analyze data output fom mixed-signal simulation using ngspice
clc; clear all; close all;
addpath('../../python-deltasigma/delsig/')
addpath('../../system-level/matlab/ctdsm/')
addpath('../../system-level/matlab/utility/')


%% ****************************************
% Load Data
% ****************************************
load ./ms_sim_out.mat
% %% ****************************************
% Specs and Params
% ****************************************
fb          = 128;    % Maximum frequency in Hz
fres        = 1/64;   % FFT resolution in Hz --> N=2^22
fin         = 18;  % input frequency in Hz
fs          = 2^16;   % in Hz
VDD         = 1.8;
nlev        = 4;
VinFS       = VDD*2/5;                  % Quantizer Input full scale
Vref        = VinFS/2;
Vlsb        = VinFS/nlev;
FSdig       = VinFS/Vlsb;               % Quantizer output full scale
LSBdig      = 1;                        % Vlsb/Vlsb
FS          = FSdig-LSBdig;             % Max. value of digital sequence, req. for FFT scaling
OSR         = fs/2/fb;

%% ****************************************
% Calc PSD
% ****************************************
N = length(data);
y = data';
y_plt = ((data')-max(data)./2);
fres = fs/N;
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R, dum2, dum3, IBNcum] = calcPSDParam(y_plt, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(IBNcum));
SNR
SNDR
IBN

% Plot binary output vector for one period of input signal
figure
stem(y_plt)
xlim([0, fs/fin]);

%% ****************************************
% Export 
% ****************************************
f = (f.*fs+fres)';
Savg = p';
T3 = table(f, Savg);
writetable(T3, 'psdCtAvgMsRes.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(IBNcum',6));
T4 = table(f, IbnCum);
writetable(T4, 'psdCtAvgMsResIBN.txt', 'Delimiter', ' ','WriteRowNames',false);
