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

%% Verify 4th order CIFB CT-DSM
clc; clear all; close all;
addpath('../../python-deltasigma/delsig/')
addpath('./ctdsm/')
addpath('./utility/')

%% ****************************************
% Specs and Params
% ****************************************
fb          = 128;                      % Maximum frequency in Hz
fres        = 1/64;                     % FFT resolution in Hz --> N=2^22
ctSteps     = 8;                        % number of oversampling steps per simulation period
fin         = 18;                       % input frequency in Hz
fs          = 2^16;                     % in Hz
VDD         = 1.8;
VinFS       = VDD*2/5;                  % Quantizer Input full scale
Vref        = VinFS/2;
FS          = 2;                        % Quantizer output full scale
ampl_dB     = -1.225;                   % in dBVref MSA
amplitude   = Vref*10.^(ampl_dB/20);    % denormalize to output full scale of quantizer
offset      = 0;
OSR         = fs/2/fb;
noiseVec_rms = [1 19 150 150].*1e-6; 
ft1         = fs;
ft2         = fs;
ft3         = fs;
ft4         = fs;
omCoeff     = 1*[ft1 ft2 ft3 ft4];                              % Unity gain frequencys (rads/s) of the integrators
b1          = 0.00614178;                                       % Input 
aCoeff      = [0.00614178 0.05549743 0.24945876 0.67129148];    % Feedback
A0Vec       = [100 100 100 100];
intOutMaxVec= [0.6 1 1 Vref];
wLimVec     = 10000.*[1 1 1 1];
eld         = 0;
interferer_ampl = 0;
finter      = 0;

%% ************************************************************
% Simulation
% ************************************************************
[y, fs, N, w1, w2, w3, w4, w1_in, w2_in, w3_in, w4_in] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeff, aCoeff, b1, Vref, A0Vec, eld, noiseVec_rms, wLimVec, [false false false false], false);
plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
SNR
SNDR
IBN
%% ************************************************************
% Scaling
% ************************************************************
w1Max = max(abs(w1));
w2Max = max(abs(w2));
w3Max = max(abs(w3));
w4Max = max(abs(w4));

%% FS = VDD*2/5
w1Max = 0.0193;
w2Max = 0.0923;
w3Max = 0.2655;
w4Max = 0.4450;
%%
alpha1 = intOutMaxVec(1)/w1Max;
alpha2 = intOutMaxVec(2)/w2Max;
alpha3 = intOutMaxVec(3)/w3Max;
% do not scale last integrator
% alpha4 = intOutMaxVec(4)/w4Max;
alpha4 = 1;

%%
a4s = alpha3*aCoeff(4);
s4 = omCoeff(4)/alpha3;
a3s = alpha2*aCoeff(3);
s3 = omCoeff(3)*alpha3/alpha2;
a2s = alpha1*aCoeff(2);
s2 = omCoeff(2)*alpha2/alpha1;
a1s = 1;
s1 = omCoeff(1)*alpha1*aCoeff(1);
VrefScaled = Vref;

%% ************************************************************
% Verify Scaling
% ************************************************************
%  aCoeffScaled = [a1s a2s a3s a4s];          
 aCoeffScaled = [1 1.7 2.7 2.5]; % [0.6 1 1 x] swing, Gm-C-OTA Integrator/RC-OTA
%  omCoeffScaled = [s1 s2 s3 s4];
omCoeffScaled = [12 23 23 18].*1e3; % [0.6 1 1 x] swing, Gm-C-OTA Integrator/RC-OTA
b1Scaled = 1;
wLimVec = 2.*intOutMaxVec;

%%
fres = 1/64;
noiseEnVec = [true false false false];
noiseVec_rms(1) = 0.01e-6;
%noiseEnVec = [true true true true];
%noiseVec_rms = [1e-6, 10e-6, 200e-6, 250e-6];
[y, fs, N, w1, w2, w3, w4, w1_in, w2_in, w3_in, w4_in] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false);
plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R, dum2, dum3, IBNcum] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
kq_sim = dot(y,downsample(w4,ctSteps))./dot(downsample(w4,ctSteps),downsample(w4,ctSteps));
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(IBNcum));
SNR
SNDR
IBN
p_sig = (amplitude/sqrt(2)).^2;
p_noise = 10.^(IBN/10);
SNR_calc = 10*log10(p_sig/p_noise)
%% Export Data for latex doc
endIdx = ceil(ctSteps*fs/fin);
t = downsample(((0:endIdx-1)./ctSteps/fs.*1e3)', 10);
x1 = downsample(w1(1:endIdx)', 10);
x2 = downsample(w2(1:endIdx)', 10);
x3 = downsample(w3(1:endIdx)', 10);
x4 = downsample(w4(1:endIdx)', 10);
T1 = table(t, x1, x2, x3, x4);
writetable(T1, 'modStatesScaled.txt', 'Delimiter', ' ','WriteRowNames',false);
endIdx = ceil(fs/fin);
v = y(1:endIdx)';
t = ((0:endIdx-1)./fs.*1e3)';
T1 = table(t, v);
writetable(T1, 'modOut.txt', 'Delimiter', ' ','WriteRowNames',false);
% clear w1 w2 w3 w4 y
% clear t x1 x2 x3 x4 v T1
%%
endIdx = ceil(ctSteps*fs/fin);
t = downsample(((0:endIdx-1)./ctSteps/fs.*1e3)', 10);
x1dot = downsample(w1_in(1:endIdx)', 10);
x2dot = downsample(w2_in(1:endIdx)', 10);
x3dot = downsample(w3_in(1:endIdx)', 10);
x4dot = downsample(w4_in(1:endIdx)', 10);
T2 = table(t, x1dot, x2dot, x3dot, x4dot);
writetable(T2, 'modIntInputsScaled.txt', 'Delimiter', ' ','WriteRowNames',false);
% clear w1_in w2_in w3_in w4_in
% clear t x1dot x2dot x3dot x4dot T2
%% 
% f1 = ((1:round(N/2))*fres)';
% S = 20*log10(abs(V(1:round(N/2))));
% T3 = table(f1, S);
% writetable(T3, 'psdCtNoisy.txt', 'Delimiter', ' ','WriteRowNames',false);
f = (f.*fs+fres)';
Savg = p';
T3 = table(f, Savg);
writetable(T3, 'psdCtAvgNoiseMSA.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(IBNcum',6));
T4 = table(f, IbnCum);
writetable(T4, 'psdCtIBNNoiseMSA.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Plot STF und NTF
% STF not correct
%kq_sim = 1.373;
s = tf('s');
b21 = -aCoeffScaled(1); b22 = -aCoeffScaled(2); b32 = -aCoeffScaled(3); b42 = -aCoeffScaled(4);
b11 = -b21;
k1 = omCoeffScaled(1)./fs; k2 = omCoeffScaled(2)./fs; k3 = omCoeffScaled(3)./fs; k4 = omCoeffScaled(4)./fs;

L0 = b11*k1*k2*k3*k4/s^4;
L1 = (((b21*k1+b22*s)*k2+b32*s^2)*k3+b42*s^3)*k4/(s^4);

L1d = c2d(L1, 1, 'impulse');

f_eval = logspace(-5, 1, 100);
z_eval = exp(1i*2*pi*f_eval);

% L1d_eval = freqz(cell2mat(L1d.Numerator), cell2mat(L1d.Denominator), f_eval, 1);
L1d_eval = evalTF(zpk(L1d), z_eval);
L0_eval = freqs(cell2mat(L0.Numerator), cell2mat(L0.Denominator), 2*pi.*f_eval);

NTF=1./(1+L1d_eval);
NTF_k=1./(1+kq_sim.*L1d_eval);

STF_k=kq_sim.*L0_eval.*NTF_k;


% STF1 = L0/(1+L1);
% NTF1d = 1/(1+L1d);
% 
% STF2 = L0/(1+kq_sim*L1);
% NTF2 = 1/(1+kq_sim*L1);
% NTF2d = NTF1d/(kq_sim+(1-kq_sim)*NTF1d);


% [fVec, NTF1_mag] = getBode(NTF1d, -1, 4, 1000);
% [fVec, NTF2_mag] = getBode(NTF2d, -1, 4, 1000);

figure;
semilogx(f_eval, 20*log10(abs(NTF)), 'Linewidth', 2.5)
hold on
semilogx(f_eval, 20*log10(abs(NTF_k)), 'Linewidth', 2.5)
semilogx(f_eval, 20*log10(abs(STF_k)), 'Linewidth', 2.5)
semilogx(f_eval, 20*log10(abs(L1d_eval)), 'Linewidth', 2.5)
% semilogx(fVec, 20*log10(NTF2_mag), 'Linewidth', 2.5)
grid on;
xlabel("Frequency in Hz")
ylabel("Magnitude in dB")
legend("NTF","NTF_k", "STF", "L1");

% [fVec, STF1_mag] = getBode(STF1, -4, 10, 100);
% [fVec, STF2_mag] = getBode(STF2, -4, 10, 100);


% figure;
% semilogx(f_eval, 20*log10(abs(STF)), 'Linewidth', 2.5)
% % hold on
% % semilogx(fVec, 20*log10(STF2_mag), 'Linewidth', 2.5)
% grid on;
% xlabel("Frequency in Hz")
% ylabel("Magnitude in dB")
% % legend("STF-synth", "STF-sim");



%% ****************************************
% Sweep input ampl to get MSA - for scaled modulator
% w/o noise, leaky int., 2nd pole, asymm. DAC
% MSA = -1.22 dBVref (360mV) --> 0.26V
% ****************************************
amplVec = linspace(Vref/2, Vref, 20);
%amplVecdB = -160:10:0;
%amplVec = Vref.*10.^(amplVecdB./20);
SNRVec = zeros(length(amplVec),1);
nofruns = length(amplVec);

for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplVec(i), offset, interferer_ampl, finter, omCoeff, aCoeff, b1, Vref, A0Vec, eld, noiseVec_rms, wLimVec, [false false false false], false);
    SNRVec(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
end

figure;
plot(20.*log10(amplVec./Vref),SNRVec, 'ro-', 'LineWidth', 2)
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("Input Amplitude [dBVref]", "Fontsize", 14);
txt = sprintf("SQNR vs. Input (Vref = %3.0f mV)", Vref*1e3);
title(txt, "Fontsize", 16);
set(gca,'FontSize',14)
grid on;
hold off;

%% Export Data for latex doc
Input = 20*log10(amplVec'./Vref);
SQNR = SNRVec;
T1 = table(Input, SQNR);
writetable(T1, 'modMSAVerifyScaledFB.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Sweep fin to get worst input frequency 
% f=18Hz
% ****************************************
finVec = 10:1:120;%25:0.05:26;
SNRVec = zeros(length(finVec),1);
for i=1:length(finVec)
   txt = sprintf("Run %d/%d", i, length(finVec));
   disp(txt)
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, finVec(i), fres, amplitude, offset, interferer_ampl, finter, omCoeff, aCoeff, b1, Vref, A0Vec, eld, noiseVec_rms, wLimVec, [false false false false], false);
   SNRVec(i) = calcPSDParam(y, N, fs, fb, finVec(i), fres, FS);
end

figure;
plot(finVec, SNRVec, 'ro-', 'LineWidth', 2);
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("fin [Hz]", "Fontsize", 14);
title("SQNR vs. Input Frequency", "Fontsize", 16);
set(gca,'FontSize',14)
grid on;

%% ****************************************
% Sweep DC Gain of all leaky integrators at the same time
%
% ****************************************
A0_dB = 10:5:40;
A0_Vec = 10.^(A0_dB./20);
SNRVec = zeros(length(A0_Vec),1);
for i=1:length(A0_Vec)
   txt = sprintf("Run %d/%d", i, length(A0_Vec));
   disp(txt)
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeff, aCoeff, b1, Vref, A0_Vec(i).*[1 1 1 1], eld, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
end

figure;
plot(A0_dB, SNRVec, 'ro-', 'LineWidth', 2);
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("A0 [dB]", "Fontsize", 14);
title("SQNR vs. Integrator DC Gain", "Fontsize", 16);
set(gca,'FontSize',14)
grid on;

%% ****************************************
% Sweep DC Gain of only one leaky integrators, keep others fixed
%
% ****************************************
A0_dB = 10:5:50;
A0_dB_fixed = 50;
A0_fixed = 10.^(A0_dB_fixed./20);
A0_Vec = round(10.^(A0_dB./20));
SNRVec1 = zeros(length(A0_Vec),1);
SNRVec2 = SNRVec1; SNRVec3 = SNRVec1; SNRVec4 = SNRVec3;
for i=1:length(A0_Vec)
   txt = sprintf("Run %d/%d", i, length(A0_Vec));
   disp(txt)
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, [A0_Vec(i) A0_fixed A0_fixed A0_fixed], eld, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec1(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, [A0_fixed A0_Vec(i) A0_fixed A0_fixed], eld, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec2(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, [A0_fixed A0_fixed A0_Vec(i) A0_fixed], eld, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec3(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, [A0_fixed A0_fixed A0_fixed A0_Vec(i)], eld, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec4(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
end

figure;
plot(A0_dB, SNRVec1, 'ro-', 'LineWidth', 2);
hold on;
plot(A0_dB, SNRVec2, 'bo-', 'LineWidth', 2);
plot(A0_dB, SNRVec3, 'go-', 'LineWidth', 2);
plot(A0_dB, SNRVec4, 'ko-', 'LineWidth', 2);
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("A0 [dB]", "Fontsize", 14);
title("SQNR vs. Integrator DC Gain", "Fontsize", 16);
legend('Int. 1','Int. 2', 'Int. 3', 'Int. 4');
set(gca,'FontSize',14)
grid on;

%% Export Data for latex doc
A0 = A0_dB';
SQNR1 = SNRVec1;
SQNR2 = SNRVec2;
SQNR3 = SNRVec3;
SQNR4 = SNRVec4;
T1 = table(A0, SQNR1, SQNR2, SQNR3, SQNR4);
writetable(T1, 'modSNRvsA0.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Sweep GBW of only one integrator, keep others fixed
%
% ****************************************
cVec = 0.5:0.5:10;
cFixed = 10;
nofruns = length(cVec);
SNRVec1 = zeros(nofruns,1);
SNRVec2 = SNRVec1; SNRVec3 = SNRVec1; SNRVec4 = SNRVec3;
noiseEnVec = [false false false false];
for i=1:nofruns
   txt = sprintf("Run %d/%d", i, nofruns);
   disp(txt)
   [y, fs, N] = simDSM4CT_FB_2bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, noiseVec_rms, wLimVec, [cVec(i) cFixed cFixed cFixed], noiseEnVec);
   SNRVec1(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, noiseVec_rms, wLimVec, [cFixed cVec(i) cFixed cFixed], noiseEnVec);
   SNRVec2(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, noiseVec_rms, wLimVec, [cFixed cFixed cVec(i) cFixed], noiseEnVec);
   SNRVec3(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FB_2bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, noiseVec_rms, wLimVec, [cFixed cFixed cFixed cVec(i)], noiseEnVec);
   SNRVec4(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
end

figure;
plot(cVec, SNRVec1, 'ro-', 'LineWidth', 2);
hold on;
plot(cVec, SNRVec2, 'bo-', 'LineWidth', 2);
plot(cVec, SNRVec3, 'go-', 'LineWidth', 2);
plot(cVec, SNRVec4, 'ko-', 'LineWidth', 2);
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("c = GBW/fs", "Fontsize", 14);
title("SQNR vs. GBW", "Fontsize", 16);
legend('Int. 1','Int. 2', 'Int. 3', 'Int. 4');
% legend('Int. 3', 'Int. 4');
set(gca,'FontSize',14)
grid on;
%% Export Data for latex doc
c = cVec';
SQNR1 = SNRVec1;
SQNR2 = SNRVec2;
SQNR3 = SNRVec3;
SQNR4 = SNRVec4;
T1 = table(c, SQNR1, SQNR2, SQNR3, SQNR4);
writetable(T1, 'modSNRvsGBW_wo_noise_add.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ***************************************************************************
% Sweep Noise RMS at the input of the (FIRST) integrator(s) to achive 130 dB SNR
% Leaky integrators 
% w/o noise: 144.18 dB SNR
% 1. Int: 1uVrms
% 2. Int: 19uVrms, 11uVrms
% 3. Int: 150uVrms, 200uVrms
% 4. Int: 150uVrms, > 200uVrms

% % ***************************************************************************
noise1_rms_calc = amplitude/sqrt(2)/10.^(130/20)*sqrt(OSR);
% noise4rmsVec = linspace(100e-6, 200e-6, 50);
% noise1rmsVec = linspace(0.1e-6, 2e-6, 50);
% noise2rmsVec = linspace(5e-6, 30e-6, 40);
% noise3rmsVec = linspace(100e-6, 250e-6, 40);
noise4rmsVec = linspace(150e-6, 300e-6, 40);
enableVec = [true true true true];
nofruns = length(noise4rmsVec);
SNRVec = zeros(nofruns,1);
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    noiseVec_rms(1) = 1e-6;%noise1rmsVec(i);
    noiseVec_rms(2) = 11e-6;%noise2rmsVec(i);
    noiseVec_rms(3) = 203e-6;%noise3rmsVec(i);
    noiseVec_rms(4) = noise4rmsVec(i);
    [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, enableVec, true);
    SNRVec(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
    disp(SNRVec(i))
    clear y
end

figure;
plot(noise4rmsVec, SNRVec, 'k', 'LineWidth', 2)
ylabel("SNR in dB", "Fontsize",14);
xlabel("Noise RMS", "Fontsize", 14);
set(gca,'FontSize',14)
grid on;

%% Export Data for latex doc
vn_rms = noise1rmsVec(1:39)';
SNR = SNRVec(1:39);
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise1.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise2rmsVec(1:32)';
SNR = SNRVec(1:32);
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise2.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise3rmsVec';
SNR = SNRVec;
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise3.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise4rmsVec';
SNR = SNRVec;
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise4.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Simulate SQNR with nom. signal amplitude and max. DC offset
% w/ Thermal noise, w/ limited Integrator DC Gain
% ****************************************
amplitude = 5e-6;
offset = 0.25;
vsignal_rms = amplitude/sqrt(2);
noiseVec_rms = [1e-6, 10e-6, 200e-6, 250e-6]; 
noiseVec_enable = [true true true true];
% wLimVec = 10.*ones(1,4);
[y, fs, N, w1, w2, w3, w4, w1_in, w2_in, w3_in, w4_in] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseVec_enable, true);
plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R, dum, dum, IBNcum] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(IBNcum));
vqnoise_rms = FS/2*10.^(IBN/20);
SNR_calc = 20.*log10(vsignal_rms/vqnoise_rms);
IBNcalc = 10*log10((amplitude/sqrt(2)).^2/(10.^(SNR/10)));
%%
f = (f.*fs+fres)';
Savg = p';
T3 = table(f, Savg);
writetable(T3, 'psdCtAvgMaxDCNomAmpl.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(IBNcum,6));
T4 = table(f, IbnCum);
writetable(T4, 'psdCtIBNMaxDCNomAmpl.txt', 'Delimiter', ' ','WriteRowNames',false);
%% ****************************************
% Verify OBG (Out of Band Gain of NTF)
% ****************************************
[y, fs, N, w1, w2, w3, w4] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec.*ones(1,4), eld, noiseVec_rms, wLimVec, [true false false false], false);
clear w1 w2 w3
w4 = downsample(w4,ctSteps);
[SNR, SNDR, IBN, P1, NBW, dum, SNHD3R] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
[SNR, SNDR, IBN, P2, NBW, dum, SNHD3R] = calcPSDParam(y-w4, N, fs, fb, fin, fres, FS); % calc PSD of Q-Error
plotPSD(P1./P2, NBW, N, fres, fb, false, false);

%% ****************************************
% Simulate SNR with max. signal amplitude and max. DC offset
% w/ Thermal noise, w/ limited Integrator DC Gain
% ****************************************
fres = 1/64;
amplitude = 10e-3;
fin = 128;
offset = 0.25;
vsignal_rms = amplitude/sqrt(2);
noiseVec_rms = [1e-6, 10e-6, 200e-6, 250e-6]; 
noiseVec_enable = [true true true true];
[y, fs, N, w1, w2, w3, w4, w1_in, w2_in, w3_in, w4_in] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec.*ones(1,4), eld, noiseVec_rms, wLimVec, noiseVec_enable, true);
plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
[SNR, sndr, IBN, V, NBW, spwr, SNHD3R, fbin, nb, ibncum]= calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(ibncum));

vqnoise_rms = 10.^(IBN/20);
SNR_calc = 20.*log10(vsignal_rms/vqnoise_rms);

%%
f = (f.*fs+fres)';
Savg = p';
T3 = table(f, Savg);
writetable(T3, 'psdCtAvgMaxDCMaxAmpl.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(IBNcum,6));
T4 = table(f, IbnCum);
writetable(T4, 'psdCtIBNMaxDCMaxAmpl.txt', 'Delimiter', ' ','WriteRowNames',false);


%% ****************************************
% Sweep third order non. lin. factor of first integrator input
% w/ Thermal noise, w/ limited Integrator DC Gain
% SNR = 99.61 dB g3=0
% ****************************************
fres = 1/64;
amplitude = 10e-3;
ampldB = 20*log10(amplitude/Vref);
offset = 0.25;
noiseVec_rms = [1e-6, 10e-6, 200e-6, 250e-6]; 
noiseVec_enable = [true true true true];
noiseVec_enable = [false false false false];
g3Vec = logspace(-2, 0, 20);  
% g3Vec = linspace(2, 3, 10);  
g3Vec = [0, g3Vec, linspace(1,5,10)];
% g3Vec = [2.4 2.5 2.6];
% g3Vec = [2.6];
nofruns = length(g3Vec);
SNRVec = zeros(nofruns,1);
SNHD3RVec = zeros(nofruns,1);
SNDRVec = zeros(nofruns,1);
HD3Vec = zeros(nofruns,1);
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FB_2bit_nonlin(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, g3Vec(i), noiseVec_enable, true);
    [SNRVec(i), SNDRVec(i), ibn, V, NBW, spwr, SNHD3RVec(i), fbin, nb, ibncum, HD3Vec(i), hd3pwr] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
    disp(HD3Vec(i));
%     clear y
end

figure;
subplot(2,1,1);
semilogx(g3Vec, 20*log10(HD3Vec), 'k', 'LineWidth', 2)
ylabel("HD3 in dB", "Fontsize",14);
xlabel("3rd Order Non. Lin. Coeff.", "Fontsize", 14);
set(gca,'FontSize',14)
grid on;

subplot(2,1,2);
% figure;
semilogx(g3Vec, SNRVec, 'k', 'LineWidth', 2)
hold on;
semilogx(g3Vec, SNHD3RVec, 'k--', 'LineWidth', 2)
semilogx(g3Vec, SNDRVec, 'k-.', 'LineWidth', 2)
ylabel("SNR, SNDR in dB", "Fontsize",14);
xlabel("3rd Order Non. Lin. Coeff.", "Fontsize", 14);
set(gca,'FontSize',14)
legend('SNR', 'SNHD3R', 'SNDR')
grid on;

figure;
plot(20*log10(HD3Vec), SNHD3RVec, 'k', 'LineWidth', 2)
hold on;
plot(20*log10(HD3Vec), SNRVec, 'k--', 'LineWidth', 2)
plot(20*log10(HD3Vec), SNDRVec, 'k-.', 'LineWidth', 2)
ylabel("SNDR in dB", "Fontsize",14);
xlabel("HD3", "Fontsize", 14);
set(gca,'FontSize',14)
legend('SNHD3R', 'SNR', 'SNDR')
grid on;

% plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
% plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
% [SNR, SNDR, IBN, V, NBW, dum, SNHD3R, dum, dum, IBNcum] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(ibncum));

%% Export Data for latex doc
g3 = g3Vec';
HD3_dB = 20*log10(HD3Vec);
SNR = SNRVec;
SNHd3R = SNHD3RVec;
T1 = table(g3, HD3_dB, SNR, SNHd3R);
writetable(T1, 'modSNDRvsHD3_add.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% ELD k0 = 0.007...direct path for ELD compensation
% ****************************************
fres = 1/16;
ctSteps = 25;
Ts_os = 1/fs/ctSteps;
tstepMin = Ts_os*fs*100; % 1/ctSteps*100%
% noiseEnVec = [true false false false];
% noiseVec_rms(1) = 0.01e-6;
noiseEnVec = [true true true true];
noiseEnVec = [false false false false];
noiseVec_rms = [1e-6, 11e-6, 203e-6, 250e-6];
eldVec = 1:ctSteps*7/10;
eldVec = [15];
nofruns = length(eldVec);
SNRVec = zeros(nofruns,1);
IBNVec = SNRVec;
amplitude = 10e-3;
offset = 0.25;
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eldVec(i), noiseVec_rms, wLimVec, noiseEnVec, false);
    [SNRVec(i), dum, IBNVec(i)] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
    disp(SNRVec(i))
%     clear y
end

figure;
subplot(2,1,1)
plot(eldVec./ctSteps.*100, SNRVec, '-ok', 'LineWidth', 2)
ylabel("SQNR [dB]", "Fontsize", 14);
xlabel("Excess Loop Delay \tau_d [%T_s]", "Fontsize", 14);
set(gca,'FontSize',16)
grid on;
hold off;

subplot(2,1,2)
plot(eldVec./ctSteps.*100, IBNVec, '-ok', 'LineWidth', 2)
ylabel("IBN [dB]", "Fontsize", 14);
xlabel("Excess Loop Delay \tau_d [%T_s]", "Fontsize", 14);
set(gca,'FontSize',16)
grid on;
hold off;

[snr, sndr, ibn, V, NBW, spwr, snhd3r, fbin, nb, ibncum] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(ibncum));

%% Export Data for latex doc
td = eldVec'./ctSteps.*100;
SNR = SNRVec;
IBN = IBNVec;
T1 = table(td, SNR, IBN);
writetable(T1, 'modSNRvsELD_comp.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% DAC Mismatch
% *******
% fres = 1/64;
% ctSteps = 8;
offset = 0.25;
amplitude = 10e-3;
noiseEnVec = [true true true true];
noiseVec_rms = [1e-6, 11e-6, 203e-6, 250e-6];
mismatch = 0;
[y1, fs, N] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "None");
mismatch = 0.1;
[y2] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "None");
[y3] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "Rand");
[y4] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "Rot");
[SNR1, SNDR1, IBN1, V1, NBW, dum, dum, dum2, dum3, IBNcum1] = calcPSDParam(y1, N, fs, fb, fin, fres, FS);
clear y1;
[SNR2, SNDR2, IBN2, V2, NBW, dum, dum, dum2, dum3, IBNcum2] = calcPSDParam(y2, N, fs, fb, fin, fres, FS);
clear y2;
[SNR3, SNDR3, IBN3, V3, NBW, dum, dum, dum2, dum3, IBNcum3] = calcPSDParam(y3, N, fs, fb, fin, fres, FS);
clear y3;
[SNR4, SNDR4, IBN4, V4, NBW, dum, dum, dum2, dum3, IBNcum4] = calcPSDParam(y4, N, fs, fb, fin, fres, FS);
clear y4;
% plotPSD(V1, NBW, N, fres, fb, true);
figure;
[f,p1] = logsmooth(V1,fin/fres);
semilogx(f.*fs+fres,p1);
hold on;
% f_band = 0:fres:fb;
[f,p2] = logsmooth(V2,fin/fres);
semilogx(f.*fs+fres,p2);
% f_band = 0:fres:fb;
% semilogx(f_band, 10*log10(IBNcum2));
[f,p3] = logsmooth(V3,fin/fres);
semilogx(f.*fs+fres,p3);
grid on;
% f_band = 0:fres:fb;
% semilogx(f_band, 10*log10(IBNcum3));
[f,p4] = logsmooth(V4,fin/fres);
semilogx(f.*fs+fres,p4);
grid on;
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(IBNcum1));
semilogx(f_band, 10*log10(IBNcum4));
legend(["Ideal", "No DEM", "Random Sel.", "DWA", "IBN-Ideal", "IBN-DWA"])

%% Export 
f = (f.*fs+fres)';
SavgIdeal = p1';
SavgNone = p2';
SavgRand = p3';
SavgDWA = p4';
T1 = table(f, SavgIdeal, SavgNone, SavgRand, SavgDWA);
writetable(T1, 'psdCtAvgDACMismatchDCMax_10per.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCumIdeal = 10*log10(downsample(IBNcum1,6));
IbnCumNone = 10*log10(downsample(IBNcum2,6));
IbnCumRand = 10*log10(downsample(IBNcum3,6));
IbnCumDWA = 10*log10(downsample(IBNcum4,6));
T2 = table(f, IbnCumIdeal, IbnCumNone, IbnCumRand, IbnCumDWA);
writetable(T2, 'psdCtIBNDACMismatchDCMax_10per.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Simulate SNR with max./nom. signal amplitude and max. DC offset 
% and 50 Hz interferer 
% w/ limited Integrator DC Gain
% ****************************************
fres = 1/64;
amplitude = 5e-6;
offset = 0.25;
interferer_ampl = 5e-3;
finter = 50;
vsignal_rms = amplitude/sqrt(2);
noiseVec_rms = [1e-6, 10e-6, 200e-6, 250e-6]; 
noiseVec_enable = [true true true true];
[y, fs, N, w1, w2, w3, w4, w1_in, w2_in, w3_in, w4_in] = simDSM4CT_FB_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, aCoeffScaled, b1Scaled, Vref, A0Vec.*ones(1,4), eld, noiseVec_rms, wLimVec, noiseVec_enable, true);
plotInternalSignals(fs, fin, ctSteps, [w1; w2; w3; w4], ["w1", "w2", "w3", "w4"], true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w2_in; w3_in; w4_in], ["w1_in", "w2_in", "w3_in", "w4_in"], true);
[SNR, sndr, IBN, V, NBW, spwr, SNHD3R, fbin, nb, ibncum]= calcPSDParam(y, N, fs, fb, fin, fres, FS, finter);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(ibncum));

vqnoise_rms = FS/2*10.^(IBN/20);
SNR_calc = 20.*log10(vsignal_rms/vqnoise_rms);

%% Export 
f = (f.*fs+fres)';
Savg = p';
T1 = table(f, Savg);
writetable(T1, 'psdCtAvgMaxDCNomAmplInterf.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(ibncum,6));
T2 = table(f, IbnCum);
writetable(T2, 'psdCtIBNMaxDCNomAmplInterf.txt', 'Delimiter', ' ','WriteRowNames',false);