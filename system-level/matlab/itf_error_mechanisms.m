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

%% Integrator Error Mechanisms
close all; clear all; clc;
addpath('../../python-deltasigma/delsig/')
addpath('./ctdsm/')
addpath('./utility/')
%%
s = tf('s');
c=20*pi;
Adc=100;
ITF1 = 2*pi/s;
ITF2 = 2*pi/(s+2*pi./Adc);
ITF3 = 2*pi*c/((s+2*pi./Adc)*(s+c));

[f, magITF1, phITF1] = getBode(ITF1, -3, 3, 100);
[f, magITF2, phITF2] = getBode(ITF2, -3, 3, 100);
[f, magITF3, phITF3] = getBode(ITF3, -3, 3, 100);

figure;
subplot(2,1,1);
semilogx(f, 20*log10(magITF1));
hold on;
semilogx(f, 20*log10(magITF2));
semilogx(f, 20*log10(magITF3));
grid on;

subplot(2,1,2);
semilogx(f, phITF1);
hold on;
semilogx(f, phITF2);
semilogx(f, phITF3);
grid on;
ylim([-180, 0]);

figure
pzmap(ITF1);
hold on;
pzmap(ITF2);
hold on;
pzmap(ITF3);
%% Export for latex doc
f = f';
magITF1_dB = 20*log10(magITF1);
magITF2_dB = 20*log10(magITF2);
magITF3_dB = 20*log10(magITF3);
T1 = table(f, magITF1_dB, phITF1, magITF2_dB, phITF2, magITF3_dB, phITF3);
%writetable(T1, 'bodeITFModels.txt', 'Delimiter', ' ','WriteRowNames',false);
%% GmC Integrator 
fs= 2.^16;
s = tf('s');
z = tf('z', 1);

kint = 0.189;
A0 = 100;
gm = 0.5e-6;

% Single Pole
go = gm/A0;
C = gm/kint;
ITF1_s = A0/(1+s*C/go);
ITF1_z1 = c2d(ITF1_s, 1, 'impulse');
ITF1_z2 = kint/(1-exp(-kint/(A0))*z^(-1));

f_eval = linspace(1e-5, 0.5, 1e6);
z_eval = exp(1i*2*pi*f_eval);

% L1d_eval = freqz(cell2mat(L1d.Numerator), cell2mat(L1d.Denominator), f_eval, 1);
ITF1_z1_eval = evalTF(zpk(ITF1_z1), z_eval);
ITF1_z2_eval = evalTF(zpk(ITF1_z2), z_eval);

figure;
semilogx(f_eval, 20*log10(abs(ITF1_z1_eval)), 'Linewidth', 2.5)
hold on
semilogx(f_eval, 20*log10(abs(ITF1_z2_eval)), 'Linewidth', 2.5)
grid on;
xlabel("Frequency in Hz")
ylabel("Magnitude in dB")
legend("c2d","hand-calc");
 
figure;
bode(ITF1_z1)
hold on;
bode(ITF1_z2)

%% Two Poles
c = 1;
GBW = c*fs;
Rp = 100;
Cp = 1000e-6;
GBW = 1/Rp/Cp;

ITF2_s =ITF1_s/(1+s*(Rp*Cp));
ITF_err_A0_GBW = 1/(s^2/(kint*GBW)+s/(kint*GBW)*(kint+GBW*(1+1/A0))+1/A0);

figure;
bode(ITF2_s)
hold on;
bode(ITF_err_A0_GBW)
grid on;
%% only GBW
ITF3_s = kint/s*1/(1+s*(Rp*Cp));
ITF_err_GBW = kint/s *(GBW/(GBW+kint)/(s/(GBW+kint)+1));
figure;
bode(ITF3_s)
hold on;
bode(ITF_err_GBW)
grid on;

%% only GBW, DT
f_eval = linspace(1e-10, 0.5*fs, 1e6);
z_eval = exp(1i*2*pi*f_eval);

GBW = 2*fs;
kint = 0.5*fs;
ITF3_s = kint/s*1/(1+s/(GBW));
ITF3_z = c2d(ITF3_s, 1/fs, 'impulse');
ITF3_z_calc = kint/GBW*(exp(GBW/fs)-1)*z^(-1)/(z^(-2)-(1+exp(GBW/fs))*z^(-1)+exp(GBW/fs));

ITF3_z_eval = evalTF(zpk(ITF3_z), z_eval);
ITF3_z_calc_eval = evalTF(zpk(ITF3_z_calc), z_eval);

figure;
semilogx(f_eval, 20*log10(abs(ITF3_z_eval)), 'Linewidth', 2.5)
hold on
semilogx(f_eval, 20*log10(abs(ITF3_z_calc_eval)), 'Linewidth', 2.5)
grid on;
xlabel("Frequency in Hz")
ylabel("Magnitude in dB")
legend("c2d","hand-calc");