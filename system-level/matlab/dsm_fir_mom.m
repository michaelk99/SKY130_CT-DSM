% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2024 Michael Koefinger
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

clc; clear all; close all;
addpath('/home/michael/tools/delsig/delsig/')
addpath('./ctdsm/')
addpath('./utility/')

%% Modulator specs
ord = 4;
k = 1.0;
nlev = 2;
optZ = 0;
topo = 'CIFF';
osr = 256;
fs = 2^16;
fb = 128;                     
fres = 1/64;                    
M = nlev -1;
delta = 2;
FS = 2*(M/2*delta);
N_FFT = ceil(fs/fres);

%% Stimulus (frequency domain plotting)
fsignal = 64;
n = 0:N_FFT-1;
ampldBFS = -6;
u = (10^(ampldBFS/20))*FS/2*sin(2*pi*fsignal./fs*n);

%% Realize Mod (CT)
ntf_synth = synthesizeNTF(ord, osr, optZ);
ntf_ss = ss(ntf_synth);
[ABCD_ct, tdac2] = realizeNTF_ct(ntf_synth, 'FF');

%% Modify coeff. for use with FIR DAC (Methods of Moments)
ntaps = 5;
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct);
c4_fir = Cc(4);
c3_fir = Cc(3)+(Cc(4)*(ntaps-1))/2;
c2_fir = Cc(2)+(6*Cc(3)*(ntaps-1)+Cc(4)*(ntaps.^2-3*ntaps+2))/12;
c1_fir = Cc(1)+(12*Cc(2)*(ntaps-1)+2*Cc(3)*(ntaps.^2-3*ntaps+2)-Cc(4)*(ntaps.^2-2*ntaps+1))/24;
Cc_fir = [c1_fir c2_fir c3_fir c4_fir];
ABCD_ct_tuned = [[Ac Bc];[Cc_fir Dc]];

%% FIR DAC State Space Descr.
f0 = 1/(ntaps+1);
num_fir = f0.*ones(1,ntaps+1);
denom_fir = zeros(1,ntaps+1);
denom_fir(1) = 1;
tf_fir = tf(num_fir, denom_fir,1);
Adc = dcgain(tf_fir);
% tf_fir = tf_fir/Adc; 
sys_fir = ss(tf_fir);

%% Assemble combined system
% INFO: [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
sys_c = ss(Ac, Bc, Cc_fir, Dc);
% sys_d = mapCtoD(sys_c);
sys_d = c2d(sys_c,1);
Ad = sys_d.A; 
Bd1 = sys_d.B(:,1); Bd2 = sys_d.B(:,2);
Cd = sys_d.C; Dd = sys_d.D;
Acomb = [Ad Bd2*sys_fir.C;
        zeros(ntaps,ord) sys_fir.A];
Bcomb = [Bd1 Bd2*sys_fir.D;
        zeros(ntaps,1) sys_fir.B];
Ccomb = [Cd zeros(1,ntaps)];
Dcomb = [0 0];
ABcomb = [Acomb Bcomb];
CDcomb = [Ccomb Dcomb];

ABCDcomb = [ABcomb;CDcomb]

%% Determine coeff. of compensational FIR DAC
% Determine pulse response of the prototype loop filter
n_imp = 15;
tvec = 1:n_imp;
l_proto = -impL1(ntf_synth,n_imp);
% Determine pulse response of the coefficient-tuned loop filter 
% with FIR DAC
[Ac, Bc, Cc, Dc] = partitionABCD(ABCDcomb);
sys_d = ss( Ac, Bc, Cc, Dc, 1 );
yy = -impulse(sys_d);
% yy = -pulse(sys_c,[0 1],1,n_imp,0);
% yy = squeeze(yy);
% Calc difference for first ntaps samples

% Plot
figure;
hold on;
plot(l_proto,'o-')
plot(yy(:,1,2),'o-')
% plot(yy2(:,1,2),'o-')
xlim([0 10])
grid on;

%% FIR DAC State Space Descr. w/ compensation DAC
ntaps = 10;
f0 = 1/(ntaps+1);
num_fir = f0.*ones(1,ntaps+1);
denom_fir = zeros(1,ntaps+1);
denom_fir(1) = 1;
tf_fir = tf(num_fir, denom_fir,1);
Adc = dcgain(tf_fir);
% tf_fir = tf_fir/Adc; 
ss_fir = ss(tf_fir);
Afir  = ss_fir.A;
%Bfir = ss_fir.B./ss_fir.B(1);
Bfir = ss_fir.B;
% Cfir = [ss_fir.C.*ss_fir.B(1); ss_fir.C.*ss_fir.B(1)];
Cfir = [ss_fir.C; ss_fir.C];
Dfir = [ss_fir.D; ss_fir.D];

% bode(ss_fir)

%% Assemble CIFF-B 
%ABCD_CIFF_B = [ 0  0  0  0  1 -1;
%                1  0  0  0  0  0;
%                0  1  0  0  0  0;
%                k2 k3 k4 0  0 -k1;
%                0  0  0  1  0  0];
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned)
A_ffb = [0 0 0 0; 1 0 0 0; 0 1 0 0; Cc(1,2) Cc(1,3) Cc(1,4) 0];
B_ffb = [1 -1; 0 0; 0 0; 0 -Cc(1,1)];
B_ffb_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 -Cc(1,1)];
C_ffb = [0 0 0 1];
D_ffb = [0 0];
D_ffb_fir = [0 0 0];

AB = [A_ffb B_ffb];
CD = [C_ffb D_ffb];
ABCD_ffb = [AB;CD];

ABCD_ffb_fir = [A_ffb B_ffb_fir;C_ffb D_ffb_fir];

% Verify
% [Ac Bc Cc Dc] = partitionABCD(ABCD_ct);
sys_c = ss(Ac,Bc,Cc,Dc);
sys_d = mapCtoD(sys_c,tdac2);
ABCD_ct_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];

[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ffb);
sys_c = ss(Ac,Bc,Cc,Dc);
sys_d = mapCtoD(sys_c,tdac2);
ABCD_ffb_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];
[snr1,amp1] = simulateSNR(ABCD_ct_sim, osr);
[snr2,amp2] = simulateSNR(ABCD_ffb_sim, osr);

figure;
hold on;
plot(amp1, snr1);
plot(amp1, snr2);
grid on;

%% Assemble combined system
% sys_c = ss(A_ffb, B_ffb_fir, C_ffb, D_ffb_fir);
sys_c = ss(Ac, Bc, Cc_fir, Dc);
% sys_d = mapCtoD(sys_c);
sys_d = c2d(sys_c,1);
Ad = sys_d.A; 
Bd1 = sys_d.B(:,1); Bd23 = sys_d.B(:,2:3);
Cd = sys_d.C; Dd = sys_d.D;
Acomb = [Ad Bd23*Cfir;
        zeros(ntaps,ord) Afir];
Bcomb = [Bd1 Bd23*Dfir;
        zeros(ntaps,1) Bfir];
Ccomb = [Cd zeros(1,ntaps)];
Dcomb = [0 0];
ABcomb = [Acomb Bcomb];
CDcomb = [Ccomb Dcomb];

ABCDcomb = [ABcomb;CDcomb]



%% Simulate, plot and compare
v1 = simulateDSM(u, ABCD_ct_sim, nlev);
v2= simulateDSM(u, ABCD_ffb_sim, nlev);
v3 = simulateDSM(u, ABCDcomb, nlev);

[SNR1, SNDR1, IBN1, V1, NBW1] = calcPSDParam(v1, N_FFT, fs, fb, fsignal, fres, FS);
[SNR2, SNDR2, IBN2, V2, NBW2] = calcPSDParam(v2, N_FFT, fs, fb, fsignal, fres, FS);
[SNR3, SNDR3, IBN3, V3, NBW3] = calcPSDParam(v3, N_FFT, fs, fb, fsignal, fres, FS);
plotPSD(V1, NBW1, N_FFT, fres, fb, true);
hold on;
[f,p] = logsmooth(V1,fsignal/fres);
semilogx(f.*fs+fres,p);
[f,p] = logsmooth(V2,fsignal/fres);
semilogx(f.*fs+fres,p);
[f,p] = logsmooth(V3,fsignal/fres);
semilogx(f.*fs+fres,p);
legend('FF','fb','FF (smoothed)','FF-B (smoothed)','FF-B FIR (smoothed)')



%% 8.9 Design Example from Bluebook
% 3rd order modulator, OSR=64, OBG=2.5
% Assume NRZ DAC shape

N = 10;
ntf = synthesizeNTF(3, 64, 0, 2.5, 0);
L1 = 1/ntf-1;
L1 = 1/ntf_synth-1;
l_1 = impulse(L1,N);
l_2 = impL1(ntf,N);

% figure; hold on; stem(l_1); stem(-l_2)

% Ideal 1st, 2nd and 3rd order paths of the loop filter (s-domain)
L1_0 = tf([1],[1]);
L1_1 = tf([1], [1 0]);
L1_2 = tf([1], [1 0 0]);
L1_3 = tf([1], [1 0 0 0]);
L1_4 = tf([1], [1 0 0 0 0]);

% Ideal impulse responses of 1st, 2nd and 3rd order paths
x0 = impulse(c2d(L1_0, 1),N);
x1 = impulse(c2d(L1_1, 1),N);
x2 = impulse(c2d(L1_2, 1),N);
x3 = impulse(c2d(L1_3, 1),N);
x4 = impulse(c2d(L1_4, 1),N);
% figure; hold on; stem(x0); stem(x1); stem(x2); stem(x3); stem(x4)

% Determine Coefficients
K_ol = [x1 x2 x3 x4]\l_1

% Closed Loop Fitting - not functional?
% h = impulse(ntf_synth,N);
% 
% h0 = conv(x0,h);
% h1 = conv(x1,h);
% h2 = conv(x2,h);
% h3 = conv(x3,h);
% h4 = conv(x4,h);
% 
% Nconv = 2*N+1;
% deltaImpl = zeros(Nconv,1);
% deltaImpl(1) = 1;
% h = impulse(ntf_synth,Nconv-1);
% rhs = deltaImpl-h;
% H = [h1 h2 h3 h4];
% 
% K_cl = [h1 h2 h3 h4]\rhs;
