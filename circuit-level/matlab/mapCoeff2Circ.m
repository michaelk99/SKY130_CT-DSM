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
Ptot = 1e-6;
Vdd = 1.8;
Vref = 0.36;
gmIdMax = 20;
gammaMOS = 0.6;
Vin_peak_max = 0.3;
nlev = 2.^2;

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
xMaxFB = [0.0195 0.0934 0.2687 0.4906];
xMaxFF = [0.3236 0.6319 2.3785 41.815];
%% Desired Swings and Trafo Matrices
xMaxDesFB = [0.6 1 1 xMaxFB(4)];
xMaxDesFF = [xMaxFF(1) xMaxFF(2) 1 1];

TFB = diag(xMaxDesFB./xMaxFB);
TFF = diag(xMaxDesFF./xMaxFF);

AFBs = TFB*AFB*inv(TFB);
AFFs = TFF*AFF*inv(TFF);

BFBs = TFB*BFB;
BFFs = TFF*BFF;

CFBs = CFB*inv(TFB);
CFFs = CFF*inv(TFF);

%% Calculate Integrator Scaling Coeff.
TFBdiag = diag(TFB);
kFB = [BFB(1,1)*TFB(1,1) TFB(2,2)/TFB(1,1) TFB(3,3)/TFB(2,2) TFB(4,4)/TFB(3,3)];
fugFB = fs.*kFB;
BFBss2 = [-1; TFBdiag(1:3).*BFB(2:4,2)];
BFBss1 = [1 0 0 0 ];
BFBss = [BFBss1; BFBss2']';
AFBss = A;

TFFdiag = diag(TFF);
kFF = [BFF(1,1)*TFF(1,1) AFF(2,1)*TFF(2,2)/TFF(1,1) AFF(3,2)*TFF(3,3)/TFF(2,2) AFF(4,3)*TFF(4,4)/TFF(3,3)];
fugFF = fs.*kFF;
BFFss = [1 -1; 0 0; 0 0; 0 0];
CFFss = CFFs;
AFFss = A;

%% System Sim Results
VnoiseBudgetVecFB = [1 10 200 250].*1e-6;
VoppVecFB = xMaxDesFB;
ADCVecFB_dB = [40 25 25 25];
ADCVecFB = 10.^(ADCVecFB_dB/20);
GBWVecFB = [1 1 2 8].*fs;

VnoiseBudgetVecFF = [1 30 200 250].*1e-6;
VoppVecFF = xMaxDesFF;
ADCVecFF_dB = [40 40 40 25];
ADCVecFF = 10.^(ADCVecFF_dB/20);
GBWVecFF = [6 1 1 1].*fs;

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
PbudgetVecFB = [0.5 0.5/3 0.5/3/2 0.5/3/2].*Ptot;
PbudgetVecFF = [0.5 0.5/3 0.5/3/2 0.5/3/2].*Ptot;
IBiasStageFB = PbudgetVecFB./Vdd;
IBiasStageFF = PbudgetVecFF./Vdd;
IoutStageFB = IBiasStageFB./4;
IoutStageFF = IBiasStageFF./4;

%% Minimum Rin for Stages 2 - 4
RVecMinFB = VoppVecFB(1:end-1)./2./IoutStageFB(1:end-1);
RVecMinFBMeg = RVecMinFB/1e6
RVecMinFF = VoppVecFF(1:end-1)./2./IoutStageFF(1:end-1);
RVecMinFFMeg = RVecMinFF/1e6

%% Single Stage OTA Specs: gm, Ro for Stages 2 - 4
GmOTAVecFB = gmIdMax.*IoutStageFB(2:4);
GmOTAVecFBuS = GmOTAVecFB./1e-6
RoOTAVecFB = ADCVecFB(2:4)./GmOTAVecFB;
RoOTAVecFBMOhm = RoOTAVecFB./1e6

GmOTAVecFF = gmIdMax.*IoutStageFF(2:4);
GmOTAVecFFuS = GmOTAVecFF./1e-6
RoOTAVecFF = ADCVecFF(2:4)./GmOTAVecFF;
RoOTAVecFFMOhm = RoOTAVecFF./1e6

%% RC - OTA Integrators 
CVecFB = 1./(fugFB(2:4).*RVecMinFB);
CVecFBpF = CVecFB./1e-12

CVecFF = 1./(fugFF(2:4).*RVecMinFF);
CVecFF(3) = CVecFF(3)/CFFss(4);
CVecFFpF = CVecFF./1e-12

%% FF Coeff
CFFVec = CFFss(1:3).*CVecFF(3);
CFFVecpF = CFFVec./1e-12

%% FB Coeff
RDACVec = RVecMinFB./abs(BFBss(2:4,2))';
RDACVecMOhm = RDACVec./1e6

%% Noise Budget OTA for Stages 2 - 4: FB
Vnoise_Rin_in_rms_Vec_FB = sqrt(8.*k.*T.*RVecMinFB.*fb);

Vnoise_DAC_in_rms_Vec_FB = RVecMinFB.*sqrt(8.*k.*T.*fb./RDACVec)
Vnoise_Amp_in_rms_Vec_FB = sqrt(VnoiseBudgetVecFB(2:end).^2-Vnoise_Rin_in_rms_Vec_FB.^2-Vnoise_DAC_in_rms_Vec_FB.^2)
Vnoise_Amp_rms_1_Vec_FB = Vnoise_Amp_in_rms_Vec_FB./(1+RVecMinFB./RDACVec);
Vnoise_Amp_rms_1_Vec_FBuV = Vnoise_Amp_rms_1_Vec_FB./1e-6
Vnoise_Amp_rms_1_Vec_gm_approx_FB = sqrt(8*k*T./GmOTAVecFB.*gammaMOS)
NEF_Vec_FB = Vnoise_Amp_rms_1_Vec_FB.^2./(Vnoise_Amp_rms_1_Vec_gm_approx_FB.^2)

% Steering current DAC
% RoutDAC = 10e6;
% gammaMOS = 2./3;
% gm_cs = 1e-6;
% Vnoise_AMPDAC_in_rms_Vec_FB = sqrt((VnoiseBudgetVecFB(2:end).^2-Vnoise_Rin_in_rms_Vec_FB.^2)./2);
% Inoise_DAC_rms_Vec_FB = Vnoise_AMPDAC_in_rms_Vec_FB./(sqrt(2).*RVecMinFB);
% Vnoise_Amp_rms_2_Vec_FB = Vnoise_AMPDAC_in_rms_Vec_FB./(1+RVecMinFB./RoutDAC)
% Inoise_DAC_th_ex = sqrt(8*k*T.*gammaMOS.*gm_cs.*fb)

%% Noise Budget OTA for Stages 2 - 4: FF
Vnoise_Rin_in_rms_Vec_FF = sqrt(8.*k.*T.*RVecMinFF.*fb);

Vnoise_DAC_in_rms_Vec_FF = zeros(1,length(RVecMinFF));
Vnoise_Amp_in_rms_Vec_FF = sqrt(VnoiseBudgetVecFF(2:end).^2-Vnoise_Rin_in_rms_Vec_FF.^2-Vnoise_DAC_in_rms_Vec_FF.^2)
Vnoise_Amp_rms_1_Vec_FF = Vnoise_Amp_in_rms_Vec_FF;
Vnoise_Amp_rms_1_Vec_FFuV = Vnoise_Amp_rms_1_Vec_FF./1e-6
Vnoise_Amp_rms_1_Vec_gm_approx_FF = sqrt(8*k*T./GmOTAVecFF.*gammaMOS);
NEF_Vec_FF = Vnoise_Amp_rms_1_Vec_FF.^2./(Vnoise_Amp_rms_1_Vec_gm_approx_FF.^2)

%% 1. Stage
Vnoise_in_density = sqrt(VnoiseBudgetVecFB(1).^2./fb);
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

C1FB = 1./(fugFB(1)*R1)
C1FF = 1./(fugFF(1)*R1)

Ro1FB = ADCVecFB(1)./Gmeff;
Ro1FF = ADCVecFF(1)./Gmeff;
Ro1FBMOhm = Ro1FB./1e6

%% Calc Unit cells of FB Steering current DACs for Spice sim (AC and Transient/MS)
Gm_cs_ac = 0.5./[1./Gmeff RDACVec]; % 2*Gm_cs_ac was used, as the feedback signal was scaled by 0.5
RDAC_unit_Vec = [1./Gmeff RDACVec]*(nlev-1);
Ics_unit = 2*Vref/nlev./RDAC_unit_Vec
Ics_unit_ms = Vref/3*Gm_cs_ac;
Ics_unit_ms_nA = Ics_unit_ms./1e-9

GmStage_nS = 1./RVecMinFB/1e-9

CL_sim_pF = 1.*[CVecFB]./1e-12
C1FB

%% Total Res and Cap for FB and FF
CtotFB = C1FB+2*sum(CVecFB)
CtotFF = C1FF+2*sum(CVecFF)+2*sum(CFFVec)
RtotFB = 2*R1+2*R1DAC+2*sum(RVecMinFB)+2*sum(RDACVec)
RtotFF = 2*R1+2*R1DAC+2*sum(RVecMinFF)

%% Area of Caps and Res: FB and FF
W_rpoly = 0.35e-6;
Rsheet = 2000; % 2kOhm pro sq
CpArea = 4e-15/1e-12; % 5fF pro um^2
L_RtotFB = RtotFB.*W_rpoly/Rsheet;
L_RtotFF = RtotFF.*W_rpoly/Rsheet;
A_RtotFB = L_RtotFB.*W_rpoly;
A_RtotFF = L_RtotFF.*W_rpoly;
A_RtotFB_mmsq = A_RtotFB./1e-6
A_RtotFF_mmsq = A_RtotFF./1e-6

A_CtotFB = CtotFB./CpArea;
A_CtotFF = CtotFF./CpArea;
A_CtotFB_mmsq = A_CtotFB./1e-6
A_CtotFF_mmsq = A_CtotFF./1e-6

A_RC_FB = A_RtotFB+A_CtotFB;
A_RC_FF = A_RtotFF+A_CtotFF;

A_RC_FB_mmsq = A_RC_FB./1e-6
A_RC_FF_mmsq = A_RC_FF./1e-6

%% Area Gain Boosters
W1 = 500e-6;
L1 = 10e-6;
W3 = 40e-6;
L3 = 80e-6;
A34 = 2*4*W3*L3;
A1 = W1*L1;

Aest_mmsq = 2*(A1+A34)./1e-6



