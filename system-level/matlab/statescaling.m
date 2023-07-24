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

%% State Scaling of FB and FF Modulators
clc; clear all; close all;

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

AFBs = TFB*AFB*inv(TFB)
AFFs = TFF*AFF*inv(TFF)

BFBs = TFB*BFB
BFFs = TFF*BFF

CFBs = CFB*inv(TFB)
CFFs = CFF*inv(TFF)

%% Calculate Integrator Scaling Coeff.
fs =2.^16;
TFBdiag = diag(TFB);
kFB = [BFB(1,1)*TFB(1,1) TFB(2,2)/TFB(1,1) TFB(3,3)/TFB(2,2) TFB(4,4)/TFB(3,3)]
fugFB_kHz = fs.*kFB/1e3
BFBss2 = [-1; TFBdiag(1:3).*BFB(2:4,2)];
BFBss1 = [1 0 0 0 ];
BFBss = [BFBss1; BFBss2']'
AFBss = A;

TFFdiag = diag(TFF);
kFF = [BFF(1,1)*TFF(1,1) AFF(2,1)*TFF(2,2)/TFF(1,1) AFF(3,2)*TFF(3,3)/TFF(2,2) AFF(4,3)*TFF(4,4)/TFF(3,3)]
fugFF_kHz = fs.*kFF/1e3
BFFss = [1 -1; 0 0; 0 0; 0 0]
CFFss = CFFs
AFFss = A;
