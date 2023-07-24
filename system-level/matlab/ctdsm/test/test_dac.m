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

%% Test different DAC waveforms for 3-lvl DAC
clear all; close all; clc;
addpath('../../../../python-deltasigma/delsig/')
addpath('../../utility/')
addpath('../')

%% NRZ
clear all; close all; clc;
Ts = 1/(2.^16);
ctSteps = 50;
Ts_os = Ts/ctSteps;
Vref = 0.36;
Vref_p = Vref;
Vref_n = -Vref;
sr = 100e6;
fact = sr/2/Vref*Ts;
%fact = 2;
%sr = fact*2*Vref/Ts;
% NRZ
DAC_NRZ(1,(1:ctSteps)) = Vref_p.*ones(1,ctSteps);
DAC_NRZ(2,(1:ctSteps)) = Vref_p.*ones(1,ctSteps); DAC_NRZ(2,(1:round(ctSteps/fact)))= Vref_n + 2*1/round(ctSteps/fact)*Vref_p*(1:round(ctSteps/fact));
DAC_NRZ(3,(1:ctSteps)) = Vref_n.*ones(1,ctSteps); DAC_NRZ(3,(1:round(ctSteps/2/fact)))= Vref_p - 2*1/round(ctSteps/2/fact)*Vref_p*(1:round(ctSteps/2/fact));
DAC_NRZ(4,(1:ctSteps)) = Vref_n.*ones(1,ctSteps);
DAC_NRZ(5,(1:ctSteps)) = zeros(1,ctSteps);
DAC_NRZ(6,(1:ctSteps)) = zeros(1,ctSteps); DAC_NRZ(6,(1:round(ctSteps/2/fact))) = DAC_NRZ(3,(1:round(ctSteps/2/fact))); DAC_NRZ(6,DAC_NRZ(6,:)<0)=0;
DAC_NRZ(7,(1:ctSteps)) = Vref_p.*ones(1,ctSteps); DAC_NRZ(7,(1:round(ctSteps/fact))) = 1/round(ctSteps/fact)*Vref_p*(1:round(ctSteps/fact));
DAC_NRZ(8,(1:ctSteps)) = zeros(1,ctSteps); DAC_NRZ(8,(1:round(ctSteps/fact))) = DAC_NRZ(2,(1:round(ctSteps/fact))); DAC_NRZ(8,DAC_NRZ(8,:)>0)=0;
DAC_NRZ(9,(1:ctSteps)) = Vref_n.*ones(1,ctSteps); DAC_NRZ(9,(1:round(ctSteps/2/fact))) = -1/round(ctSteps/2/fact)*Vref_p*(1:round(ctSteps/2/fact));
sr = 2*Vref/(round(ctSteps/fact)*Ts_os);

% jitter = 9;
% DAC = [DAC_NRZ(3,1:ctSteps/2) DAC_NRZ(3,ctSteps/2+jitter:end), zeros(1, jitter-1)];
% figure;
% stem([DAC_NRZ(1,:) DAC, DAC_NRZ(4,:), DAC_NRZ(2,:), DAC_NRZ(3,:)])
% grid on;
 
figure;
stem(DAC_NRZ(6,1:round(ctSteps)));
hold on;
stem(DAC_NRZ(7,1:round(ctSteps)));
stem(DAC_NRZ(8,1:round(ctSteps)));
stem(DAC_NRZ(9,1:round(ctSteps)));
grid on;
