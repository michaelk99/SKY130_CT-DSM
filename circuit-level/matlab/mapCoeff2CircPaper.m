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

%% Map state scaled modulator to circuit components, FB and FF
clc; clear all; close all;

%% Specs
k = 1.38e-23;
T = 300;
fb = 128;
fs = 2.^16;
Ptot = 10e-6;
P24tot = 1e-6;
P24 = P24tot/2;
Vdd = 1.8;
Vref = 0.6;
gmIdMax = 20;
gammaMOS = 0.6;
Vin_peak_max = 0.3;
nlev = 2;

%% Prototype Modulators
b12 = -0.00614;
b22 = -0.05550;
b32 = -0.24946;
b42 = -0.67129;
c1 = abs(b42);
c2 = abs(b32);
c3 = abs(b22);
c4 = abs(b12);

A = [0 0 0 0;
       1 0 0 0;
       0 1 0 0;
       0 0 1 0;
      ];
AFB = A;
AFF = 0.9.*A;
BFB = [abs(b12) b12; 0 b22; 0 b32; 0 b42];
BFF = [0.9 -0.9; 0 0; 0 0; 0 0];
CFB = [0 0 0 1];
CFF = [c1 c2 c3 c4];
%% Max States form Simulation
xMaxFF = [1.0796 1.9088 5.8839 61.55];
%% Desired Swings and Trafo Matrices
xMaxDesFF = [0.6 1 1 1];

TFF = diag(xMaxDesFF./xMaxFF);

AFFs = TFF*AFF*inv(TFF);

BFFs = TFF*BFF;

CFFs = CFF*inv(TFF);

%% Calculate Integrator Scaling Coeff.

TFFdiag = diag(TFF);
kFF = [BFF(1,1)*TFF(1,1) AFF(2,1)*TFF(2,2)/TFF(1,1) AFF(3,2)*TFF(3,3)/TFF(2,2) AFF(4,3)*TFF(4,4)/TFF(3,3)];
fugFF = fs.*kFF;
BFFss = [1 -1; 0 0; 0 0; 0 0];
CFFss = CFFs;
AFFss = A;

%% System Sim Results

VnoiseBudgetVecFF = [1 47 300 600].*1e-6;
VoppVecFF = xMaxDesFF;
ADCVecFF_dB = [45 45 45 25];
ADCVecFF = 10.^(ADCVecFF_dB/20);
% GBWVecFF = [6 1 1 1].*fs;

%% Feedforward ELD compensation
tau = 0.5;
k4 = CFFss(4);
k3 = CFFss(3) + k4*tau;
k2 = CFFss(2) + k3*tau + k4*(tau.^2/2);
k1 = CFFss(1) + k2*tau + k3*(tau.^2/2) + k4*(tau.^3/6);
k0 = CFFss(1)*tau + k2*(tau.^2/2) + k3*(tau.^3/6) + k4*(tau.^4/24);
kVec = [k0 k1 k2 k3 k4]
% CFFss = kVec(2:end);
%% Current Budget

PbudgetVecFF = [Ptot P24./2  P24./4 P24./4];

IBiasStageFF = PbudgetVecFF./Vdd;

IoutStageFF = IBiasStageFF./4;

%% Minimum Rin for Stages 2 - 4
RVecMinFF = VoppVecFF(1:end-1)./2./IoutStageFF(1:end-1);
RVecMinFFMeg = RVecMinFF/1e6

%% Single Stage OTA Specs: gm, Ro for Stages 2 - 4
GmOTAVecFF = gmIdMax.*IoutStageFF(2:4);
GmOTAVecFFuS = GmOTAVecFF./1e-6
RoOTAVecFF = ADCVecFF(2:4)./GmOTAVecFF;
RoOTAVecFFMOhm = RoOTAVecFF./1e6

%% RC - OTA Integrators 

CVecFF = 1./(fugFF(2:4).*RVecMinFF);
CVecFF(3) = CVecFF(3)/CFFss(4);
CVecFFpF = CVecFF./1e-12

%% FF Coeff
CFFVec = CFFss(1:3).*CVecFF(3);
CFFVecpF = CFFVec./1e-12

%% Noise Budget OTA for Stages 2 - 4: FF
Vnoise_Rin_in_rms_Vec_FF = sqrt(8.*k.*T.*RVecMinFF.*fb);

Vnoise_DAC_in_rms_Vec_FF = zeros(1,length(RVecMinFF));
Vnoise_Amp_in_rms_Vec_FF = sqrt(VnoiseBudgetVecFF(2:end).^2-Vnoise_Rin_in_rms_Vec_FF.^2-Vnoise_DAC_in_rms_Vec_FF.^2)
Vnoise_Amp_rms_1_Vec_FF = Vnoise_Amp_in_rms_Vec_FF;
Vnoise_Amp_rms_1_Vec_FFuV = Vnoise_Amp_rms_1_Vec_FF./1e-6
Vnoise_Amp_rms_1_Vec_gm_approx_FF = sqrt(8*k*T./GmOTAVecFF.*gammaMOS);
NEF_Vec_FF = Vnoise_Amp_rms_1_Vec_FF.^2./(Vnoise_Amp_rms_1_Vec_gm_approx_FF.^2)

%% 1. Stage
Vnoise_in_density = sqrt(VnoiseBudgetVecFF(1).^2./fb);
xRs = 1/4;
xAmp = 1/2;
Vnoise_Rs_in = xRs.*Vnoise_in_density.^2;
Vnoise_CS_in = xRs.*Vnoise_in_density.^2;
R1max = Vnoise_Rs_in./(8*k*T);
R1maxkOhm = R1max./1e3
R1 = 50e3;
Ibias1 = Vin_peak_max./2/R1
R1DAC = R1;
Gmeff = 1/R1;
Inoise_CS_rms = sqrt(Vnoise_CS_in*Gmeff.^2);
Vnoise_Rs_in_rms = sqrt(8*k*T*R1);
Vnoise_RDAC_in_rms = sqrt(8*k*T*R1.^2/R1DAC);
Vnoise_CS_in_rms = sqrt(Vnoise_CS_in);
Vnoise_Ampboost_in_rms = sqrt(0.5*(Vnoise_in_density.^2-Vnoise_Rs_in_rms.^2-Vnoise_RDAC_in_rms.^2-Vnoise_CS_in))

C1FF = 1./(fugFF(1)*R1)/2 % Half it as wug is defined by Gmeff/2

Ro1FF = ADCVecFF(1)./Gmeff;
Ro1FFMOhm = Ro1FF./1e6

%% Total Res and Cap for FB and FF

CtotFF = C1FF+2*sum(CVecFF)+2*sum(CFFVec)
RtotFF = 2*R1+2*R1DAC+2*sum(RVecMinFF)

%% Area of Caps and Res: FB and FF
W_rpoly = 0.35e-6;
Rsheet = 2000; % 2kOhm pro sq
CpArea = 4e-15/1e-12; % 5fF pro um^2

L_RtotFF = RtotFF.*W_rpoly/Rsheet;

A_RtotFF = L_RtotFF.*W_rpoly;

A_RtotFF_mmsq = A_RtotFF./1e-6


A_CtotFF = CtotFF./CpArea;

A_CtotFF_mmsq = A_CtotFF./1e-6


A_RC_FF = A_RtotFF+A_CtotFF;


A_RC_FF_mmsq = A_RC_FF./1e-6

%% Area Gain Boosters
W1 = 500e-6;
L1 = 10e-6;
W2 = 8e-6;
L2 = 10e-6;
W3 = 40e-6;
L3 = 80e-6;
Wcn = 20e-6;
Lcn = 1.5e-6;
Wcp = 10e-6;
Lcp = 3.5e-6;
Acp = Wcp*Lcp;
Acn = Wcn*Lcn;
A2 = W2*L2;
A34 = 2*4*W3*L3;
A1 = W1*L1;
Aauxamp = 2*(A1+A34+Acn+Acp)+A2;
Aauxamp_mmsq = Aauxamp./1e-6

%% Area Main Transconductor
W1 = 10e-6;
L1 = 1.5e-6;
W2 = 30e-6;
L2 = 20e-6;
W3 = 10e-6;
L3 = 80e-6;
A34 = 2*4*W3*L3;
A1 = W1*L1;
A2 = W2*L2;
A3 = W3*L3;

Amain_gm = 2*A1+A2+2*A3;
Amain_gm_mmsq = Amain_gm./1e-6

%% Total Area Est.

Atot_est_mmsq = (Amain_gm+Aauxamp+A_RC_FF)./1e-6

%% Total Current Budgets per Stage, incl. CMFB
Ibudget24 = [P24tot./2 P24tot./4 P24tot./4]./Vdd


