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

%% Verify 4th order CIFF CT-DSM
clc; clear all; close all;
addpath('../../python-deltasigma/delsig/')
addpath('./ctdsm/')
addpath('./utility/')

%% ****************************************
% Specs and Params
% ****************************************
fb          = 128;                      % Maximum frequency in Hz
fres        = 1/64;                     % FFT resolution in Hz
ctSteps     = 8;                        % number of oversampling steps per simulation period
fin         = 18;                       % input frequency in Hz
fs          = 2^16;                     % in Hz
VDD         = 1.8;
VinFS       = VDD*2/3;                  % Quantizer Input full scale
Vref        = VinFS/2;
FS          = 2;                        % Quantizer output full scale
ampl_dB     = -4.4;                    % in dBFS MSA
amplitude   = Vref*10.^(ampl_dB/20);    % denormalize to output full scale of quantizer
offset      = 0;
OSR         = fs/2/fb;
noiseVec_rms = [1e-6, 30e-6, 200e-6, 300e-6]; 
ft1         = fs;
ft2         = fs;
ft3         = fs;
ft4         = fs;
omCoeff     = 0.9.*[ft1 ft2 ft3 ft4];                            % Unity gain frequencys (rads/s) of the integrators
a1          = -1;                                               % DAC Feedback
b1          = 1;                                                % Input 
cCoeff      = [0.67129148 0.24945876 0.05549743 0.00614178];    % Feedforward
A0Vec       = [100 100 100 100];
intOutMaxVec= [0.6 1 1 1];
wLimVec     = 1000.*[1 1 1 1];
eld         = 0;
interferer_ampl = 0;
finter      = 0;

%% ************************************************************
% Simulation
% ************************************************************
[y, fs, N, w1, w2, w3, w4, wsum, w1_in] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, 0, 50, omCoeff, cCoeff, Vref, A0Vec, 0, noiseVec_rms, wLimVec, [false false false false], false);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w1; w2; w3; w4], ["Input Int. 1", "Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], true)
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
SNR
SNDR
IBN
%% ************************************************************
% Scaling
% ************************************************************
idxPer1 = ceil(ctSteps*fs/fin);
w1Max = max(abs(w1));
w2Max = max(abs(w2));
w3Max = max(abs(w3));
w4Max = max(abs(w4));

% Only scale outputs of 3rd and 4th stage
alpha1 = 1;%intOutMaxVec(1)/w1Max;
alpha2 = 1;%intOutMaxVec(2)/w2Max;
alpha3 = intOutMaxVec(3)/w3Max;
alpha4 = intOutMaxVec(4)/w4Max;
%%
c4s = cCoeff(4)/alpha4;
s4 = omCoeff(4)*alpha4/alpha3;
c3s = cCoeff(3)/alpha3;
s3 = omCoeff(3)*alpha3/alpha2;
c2s = cCoeff(2)/alpha2;
s2 = omCoeff(2)*alpha2/alpha1;
c1s = cCoeff(1)/alpha1;
s1 = omCoeff(1)*alpha1;

%% ************************************************************
% Verify Scaling
% ************************************************************
% cCoeffScaled = [c1s c2s c3s c4s];           
% cCoeffScaled = [0.6713 0.2495 0.1883 0.226];   % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
cCoeffScaled = [0.6713 0.2495 0.327 0.378];   % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
% omCoeffScaled = [s1 s2 s3 s4];                
% omCoeffScaled = [5.89 5.89 1.74 0.543].*1e4;    % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
omCoeffScaled = [5.89 5.89 1.00 0.564].*1e4;    % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
wLimVec = 2.*intOutMaxVec;

%% save
% cCoeffScaled = [c1s c2s c3s c4s];           
cCoeffScaled = [0.6713 0.2495 0.129 0.179];   % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
% omCoeffScaled = [s1 s2 s3 s4];                
omCoeffScaled = [5.24 5.24 2.26 0.418].*1e4;    % 1bit Quant Vref = 0.36, 0.3 0.5 1 1 max swing
%%
noiseEnVec = [true false false false];
noiseVec_rms(1) = 0.01e-6;
[y, fs, N, w1, w2, w3, w4, wsum, w1_in] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, 0, 50, omCoeffScaled, cCoeffScaled, Vref, A0Vec, 0, noiseVec_rms, wLimVec, noiseEnVec, false);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w1; w2; w3; w4], ["Input Int. 1", "Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], true)
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
%% ****************************************
% Sweep input ampl to get MSA - for scaled modulator
% w/o noise, leaky int., 2nd pole, asymm. DAC
% MSA = -1.22 dBVref (360mV) --> 0.26V
% ****************************************
amplVecdB1 = [-160 -140 -120 -100 -80 -60 -40 -20 -15 -10 -9 -8 -7 -6];
amplVecdB2 = -5:0.2:-3.4;
amplVecdB = [amplVecdB1 amplVecdB2];
amplVec = Vref.*10.^(amplVecdB./20);
SNRVec = zeros(length(amplVec),1);
SNDRVec = SNRVec;
nofruns = length(amplVec);

for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplVec(i), offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, [false false false false], false);
    [SNRVec(i), SNDRVec(i)] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
end

figure;
plot(amplVecdB, SNRVec, 'ro-', 'LineWidth', 2)
hold on;
plot(amplVecdB, SNDRVec, 'ro--', 'LineWidth', 2)
ylabel("SQNR [dB]", "Fontsize",14);
xlabel("Input Amplitude [dBVref]", "Fontsize", 14);
txt = sprintf("SQNR vs. Input (Vref = %3.0f mV)", Vref*1e3);
title(txt, "Fontsize", 16);
set(gca,'FontSize',14)
legend('SQNR','SQNDR');
grid on;
hold off;

%% Export Data for latex doc
Input = amplVecdB';
SQNR = SNRVec;
T1 = table(Input, SQNR);
writetable(T1, 'SQNR_vs_input_FF_1bit.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Sweep fin to get worst input frequency
% f=18Hz
% ****************************************
finVec = 10:1:120;
SNRVec = zeros(length(finVec),1);
for i=1:length(finVec)
   [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, finVec(i), fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, 0, noiseVec_rms, wLimVec, [false false false false], false);
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
   [y, fs, N] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0_Vec(i).*[1 1 1 1], 0, noiseVec_rms, wLimVec, [false false false false], true);
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
   [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, [A0_Vec(i) A0_fixed A0_fixed A0_fixed], 0, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec1(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, [A0_fixed A0_Vec(i) A0_fixed A0_fixed], 0, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec2(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, [A0_fixed A0_fixed A0_Vec(i) A0_fixed], 0, noiseVec_rms, wLimVec, [false false false false], true);
   SNRVec3(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, [A0_fixed A0_fixed A0_fixed A0_Vec(i)], 0, noiseVec_rms, wLimVec, [false false false false], true);
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
writetable(T1, 'SNRvsA0_FF_1bit.txt', 'Delimiter', ' ','WriteRowNames',false);

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
   [y, fs, N] = simDSM4CT_FF_1bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, cCoeffScaled, Vref, noiseVec_rms, wLimVec, [cVec(i) cFixed cFixed cFixed], noiseEnVec);
   SNRVec1(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, cCoeffScaled, Vref, noiseVec_rms, wLimVec, [cFixed cVec(i) cFixed cFixed], noiseEnVec);
   SNRVec2(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, cCoeffScaled, Vref, noiseVec_rms, wLimVec, [cFixed cFixed cVec(i) cFixed], noiseEnVec);
   SNRVec3(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
   clear y
   [y, fs, N] = simDSM4CT_FF_1bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeffScaled, cCoeffScaled, Vref, noiseVec_rms, wLimVec, [cFixed cFixed cFixed cVec(i)], noiseEnVec);
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
writetable(T1, 'modSNRvsGBW_wo_noise_FF.txt', 'Delimiter', ' ','WriteRowNames',false);

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
% noise2rmsVec = linspace(5e-6, 100e-6, 10);
noise3rmsVec = linspace(10e-6, 50e-3, 20);
%noise4rmsVec = linspace(150e-6, 300e-6, 40);
enableVec = [true true true false];
nofruns = length(noise3rmsVec);
SNRVec = zeros(nofruns,1);
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    noiseVec_rms(1) = 1e-6;%noise1rmsVec(i);
    noiseVec_rms(2) = 47e-6;%noise2rmsVec(i);
    noiseVec_rms(3) = noise3rmsVec(i);
    noiseVec_rms(4) = 300e-6;%noise4rmsVec(i);
    [y, fs, N] = simDSM4CT_FF_1bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, enableVec, true);
    SNRVec(i) = calcPSDParam(y, N, fs, fb, fin, fres, FS);
    disp(SNRVec(i))
    clear y
end

figure;
plot(noise3rmsVec, SNRVec, 'k', 'LineWidth', 2)
ylabel("SNR in dB", "Fontsize",14);
xlabel("Noise RMS", "Fontsize", 14);
set(gca,'FontSize',14)
grid on;

%% Export Data for latex doc
vn_rms = noise1rmsVec(1:40)';
SNR = SNRVec(1:40);
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise1_FF.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise2rmsVec';
SNR = SNRVec;
T1 = table(vn_rms, SNR);
writetable(T1, 'SNRvsNoise2_FF_1bit.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise3rmsVec';
SNR = SNRVec;
T1 = table(vn_rms, SNR);
writetable(T1, 'SNRvsNoise3_FF_1bit.txt', 'Delimiter', ' ','WriteRowNames',false);
%% Export Data for latex doc
vn_rms = noise4rmsVec';
SNR = SNRVec;
T1 = table(vn_rms, SNR);
writetable(T1, 'modSNRvsNoise4_FF.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Simulate SQNR with nom. signal amplitude and max. DC offset
% w/o Thermal noise, w/ limited Integrator DC Gain
% ****************************************
amplitude = 5e-6;
offset = 0.25;
vsignal_rms = amplitude/sqrt(2);
noiseVec_enable = [false false false false];
[y, fs, N, w1, w2, w3, w4, wsum] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, 0, noiseVec_rms, wLimVec, noiseVec_enable, true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w1; w2; w3; w4], ["Input Int. 1", "Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], true)
[SNR, SNDR, IBN, V, NBW, dum, SNHD3R] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
vqnoise_rms = 10.^(IBN/20);
SNR_calc = 20.*log10(vsignal_rms/vqnoise_rms);

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
[y, fs, N, w1, w2, w3, w4, wsum] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, 0, noiseVec_rms, wLimVec, [false false false false], true);
clear w1 w2 w3 w4
[SNR, SNDR, IBN, P1, NBW, dum, SNHD3R] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
[SNR, SNDR, IBN, P2, NBW, dum, SNHD3R] = calcPSDParam(y-wsum, N, fs, fb, fin, fres, FS); % calc PSD of Q-Error
plotPSD(P1./P2, NBW, N, fres, fb, false);

%% ****************************************
% Simulate SQNR with max. signal amplitude and max. DC offset
% w/ Thermal noise, w/ limited Integrator DC Gain
% ****************************************
fres = 1/64;
amplitude = 10e-3;
offset = 0.25;
vsignal_rms = amplitude/sqrt(2);
noiseVec_rms = [1e-6, 30e-6, 200e-6, 300e-6]; 
noiseVec_enable = [true true true true];
[y, fs, N, w1, w2, w3, w4, wsum, w1_in] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, 0, noiseVec_rms, wLimVec, noiseVec_enable, true);
plotInternalSignals(fs, fin, ctSteps, [w1_in; w1; w2; w3; w4], ["Input Int. 1", "Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], true)
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
writetable(T3, 'psdCtAvgMaxDCMaxAmpl_FF.txt', 'Delimiter', ' ','WriteRowNames',false);
f = downsample(f_band', 6);
IbnCum = 10*log10(downsample(IBNcum,6));
T4 = table(f, IbnCum);
writetable(T4, 'psdCtIBNMaxDCMaxAmpl_FF.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Sweep third order non. lin. factor of first integrator input
% w/ Thermal noise, w/ limited Integrator DC Gain
% SNR = 99.61 dB g3=0
% ****************************************
fres = 1/64;
amplitude = 10e-3;
ampldB = 20*log10(amplitude/Vref);
offset = 0.25;
noiseVec_rms = [1e-6, 30e-6, 200e-6, 250e-6]; 
noiseVec_enable = [true true true true];
g3Vec = logspace(-2, 0, 20);  
% g3Vec = linspace(2, 3, 10);  
g3Vec = [0, g3Vec, linspace(1,5,10)];
% g3Vec = [2.4 2.5 2.6];
% g3Vec = [0];
nofruns = length(g3Vec);
SNRVec = zeros(nofruns,1);
SNHD3RVec = zeros(nofruns,1);
HD3Vec = zeros(nofruns,1);
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FF_2bit_nonlin(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, g3Vec(i), noiseVec_enable, false);
    [SNRVec(i), sndr, ibn, V, NBW, spwr, SNHD3RVec(i), fbin, nb, ibncum, HD3Vec(i), hd3pwr] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
    disp(HD3Vec(i));
    %clear y
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
ylabel("SNR, SNDR in dB", "Fontsize",14);
xlabel("3rd Order Non. Lin. Coeff.", "Fontsize", 14);
set(gca,'FontSize',14)
legend('SNR', 'SNHD3R')
grid on;

figure;
plot(20*log10(HD3Vec), SNHD3RVec, 'k', 'LineWidth', 2)
hold on;
plot(20*log10(HD3Vec), SNRVec, 'k--', 'LineWidth', 2)
ylabel("SNDR in dB", "Fontsize",14);
xlabel("HD3", "Fontsize", 14);
set(gca,'FontSize',14)
legend('SNHD3R', 'SNR')
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
% g3 = g3Vec';
% HD3_dB = 20*log10(HD3Vec);
% SNR = SNRVec;
% SNHd3R = SNHD3RVec;
T1 = table(g3, HD3_dB, SNR, SNHd3R);
writetable(T1, 'modSNDRvsHD3_FF.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% Verify STF and NTF
% *****************************************
s = tf('s');
Ts = 1/fs;
c1 = cCoeffScaled(1); c2 = cCoeffScaled(2); c3 = cCoeffScaled(3); c4 = cCoeffScaled(4);
b1 = 1; a1 = 1;
k1 = omCoeffScaled(1); k2 = omCoeffScaled(2); k3 = omCoeffScaled(3); k4 = omCoeffScaled(4);

L0 = b1*k1*(c1*s^3+c2*k2*s^2+c3*k2*k3*s+c4*k2*k3*k4)/s^4;
L1 = a1*k1*(c1*s^3+c2*k2*s^2+c3*k2*k3*s+c4*k2*k3*k4)/s^4;
DAC_zoh = (1-exp(-s*Ts))/s;

STF = L0/(1+L1);
NTF = 1/(1+L1);
figure;
bode(STF);
figure;
bode(NTF);
figure;
bode(DAC_zoh);
figure;
bode(L0);


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
noiseVec_rms = [1e-6, 11e-6, 203e-6, 250e-6];
eldVec = 1:ctSteps*7/10;
nofruns = length(eldVec);
SNRVec = zeros(nofruns,1);
IBNVec = SNRVec;
for i=1:nofruns
    txt = sprintf("Run %d/%d", i, nofruns);
    disp(txt)
    [y, fs, N] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eldVec(i), noiseVec_rms, wLimVec, noiseEnVec, false);
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
writetable(T1, 'modSNRvsELD_FF.txt', 'Delimiter', ' ','WriteRowNames',false);

%% ****************************************
% DAC Mismatch
% *******
% fres = 1/64;
% ctSteps = 8;
offset = 0.25;
% offset = 0;
amplitude = 10e-3;
% amplitude   = Vref*10.^(ampl_dB/20);
noiseEnVec = [true true true true];
noiseVec_rms = [1e-6, 11e-6, 203e-6, 250e-6];
mismatch = 0;
[y1, fs, N] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "None");
mismatch = 0.1;
[y2] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "None");
[y3] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "Rand");
[y4] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled, Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false, mismatch, "Rot");
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
% Try ELD Compensation
% *****************************************
fres = 1/16;
ctSteps = 24;
Ts_os = 1/fs/ctSteps;
tstepMin = Ts_os*fs*100; % 1/ctSteps*100%
% noiseEnVec = [true false false false];
% noiseVec_rms(1) = 0.01e-6;
noiseEnVec = [true true true true];
noiseVec_rms = [1e-6, 11e-6, 203e-6, 250e-6];
eld = ctSteps/4;
k0 = 0.3932;
kVec = [0.9151 0.4117 0.2604 0.2567];

[y, fs, N] = simDSM4CT_FF_2bit(OSR, ctSteps, fb, fin, fres, amplitude, offset, interferer_ampl, finter, omCoeffScaled, cCoeffScaled , Vref, A0Vec, eld, noiseVec_rms, wLimVec, noiseEnVec, false);
[snr, sndr, ibn, V, NBW, spwr, snhd3r, fbin, nb, ibncum] = calcPSDParam(y, N, fs, fb, fin, fres, FS);
plotPSD(V, NBW, N, fres, fb, true);
hold on;
[f,p] = logsmooth(V,fin/fres);
semilogx(f.*fs+fres,p);
f_band = 0:fres:fb;
semilogx(f_band, 10*log10(ibncum));
snr