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
ntaps = 3;
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct);
c4_fir = Cc(4);
c3_fir = Cc(3)+(Cc(4)*(ntaps-1))/2;
c2_fir = Cc(2)+(6*Cc(3)*(ntaps-1)+Cc(4)*(ntaps.^2-3*ntaps+2))/12;
c1_fir = Cc(1)+(12*Cc(2)*(ntaps-1)+2*Cc(3)*(ntaps.^2-3*ntaps+2)-Cc(4)*(ntaps.^2-2*ntaps+1))/24;
Cc_fir = [c1_fir c2_fir c3_fir c4_fir];
ABCD_ct_tuned = [[Ac Bc];[Cc_fir Dc]];

%% FIR DAC State Space Descr.
f0 = 1/(ntaps);
num_fir = f0.*ones(1,ntaps);
denom_fir = zeros(1,ntaps);
denom_fir(1) = 1;
tf_fir = tf(num_fir, denom_fir, 1);
Adc = dcgain(tf_fir);
% tf_fir = tf_fir/Adc; 
sys_fir = ss(tf_fir);
% figure; impulse(sys_fir)

if ntaps == 2
    sys_fir.C = sys_fir.B;
    sys_fir.B = 1;
end

%% Differentiator State Space Descr.
num_dif = [1 -1];
denom_dif = [1 0];
tf_dif = tf(num_dif, denom_dif, 1);
sys_dif = ss(tf_dif);

%% Determine coeff. of compensational FIR DAC
n_imp = ntaps+5;
impl_dt_ntf = -impL1(ntf_synth,n_imp);

% Determine pulse response of the prototype loop filter
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct);
sys_ct = ss( Ac, Bc, Cc, Dc);
impl_ct = -pulse(sys_ct, [0 1], 1, n_imp, 0);
impl_ct = squeeze(impl_ct);

% Determine pulse response of the coefficient-tuned loop filter 
% with FIR DAC
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
Bc(1,2) = -f0;
sys_ct_tuned = ss( Ac, Bc, Cc, Dc);
impl_ct_tuned = -pulse(sys_ct_tuned, [0 ntaps], 1, n_imp, 0);
impl_ct_tuned = squeeze(impl_ct_tuned);

% Calc difference for first ntaps samples
fc = impl_ct(2:ntaps,2)-impl_ct_tuned(2:ntaps,2);

% Plot
% tvec = 0:n_imp;
% fc_plt = [0 transpose(fc) zeros(1,n_imp-ntaps+1)];
% figure;
% hold on;
% plot(tvec, impl_dt_ntf,'*-','LineWidth',1)
% plot(tvec, impl_ct(:,2),'o-','LineWidth',1)
% plot(tvec, impl_ct_tuned(:,2),'o-','LineWidth',1)
% stem(tvec, fc_plt)
% % plot(yy2(:,1,2),'o-')
% xlim([0 n_imp])
% ylim([0 max(impl_dt_ntf)])
% set(gca,'FontSize',14)
% title('Sampled Loop Filter Impulse Responses','Fontsize', 14)
% legend('NTF-Prototype', 'CT-Prototype', 'CT FIR-tuned','Coeff. of Fc(z)','Fontsize', 14)
% ylabel('p(t)','Fontsize', 14)
% xlabel('t (s)','Fontsize', 14)
% grid on;

%% Add direct path input to state space description of CT prototype
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
Bc_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 0];
Dc_fir = [0 0 -1];

%% Add first order feedback path to state space description of CT prototype
% for alternative FIR compensation
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
% Bc_fir_alt = [1 -1 0; 0 0 0; 0 0 -1; 0 0 0];
% Dc_fir_alt = [0 0 0];
%% FIR DAC State Space Descr. w/ compensation DAC
Afir  = sys_fir.A;
%Bfir = ss_fir.B./ss_fir.B(1);
Bfir = sys_fir.B;
% Cfir = [ss_fir.C.*ss_fir.B(1); ss_fir.C.*ss_fir.B(1)];
Cfir = [sys_fir.C; fc'];
Dfir = [sys_fir.D; 0];
% Cfir = [sys_fir.C; 0 fc(2:ntaps-1)'];
% Dfir = [sys_fir.D; fc(1)];

sys_fir = ss(Afir, Bfir, Cfir, Dfir, 1);

figure; bode(sys_fir); title('Bode Plot of FIR + Comp.')


% Add differntiator after compensation DAC
Adif = zeros(1,1);
Bdif = [0 1];
Cdif = [0; -1];
Ddif = [1 0; 0 1];
sys_dif = ss(Adif, Bdif, Cdif, Ddif, 1);
figure
bode(sys_dif);

sys_firdif = series(sys_fir, sys_dif);

% Add differntiator before compensation DAC
% Adif = zeros(1,1);
% Bdif = 1;
% Cdif = [0; -1];
% Ddif = [1; 1];
% sys_dif = ss(Adif, Bdif, Cdif, Ddif, 1);
% 
% figure
% bode(sys_dif);

% 
% figure
% bode(sys_firdif)
% hold on;
% bode(sys_diffir)
% title('Bode Plot FIR-DIF Cascade')

Afirdif = sys_firdif.A;
Bfirdif = sys_firdif.B;
Cfirdif = sys_firdif.C;
Dfirdif = sys_firdif.D;

% dimAdif = size(Adif);
% Afirdif = [Afir zeros(ntaps-1,dimAdif(2)); Bdif*Cfir Adif];
% Bfirdif = [Bfir;Bdif*Dfir];
% Cfirdif = [Ddif*Cfir Cdif];
% Dfirdif = Ddif*Dfir;
sys_firdif = ss(Afirdif, Bfirdif, Cfirdif, Dfirdif, 1);
figure;bode(sys_firdif)
figure; impulse(sys_firdif); title('Impulse Response of FIR + Dif.')

%% Assemble combined system
% % INFO: [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
% sys_c = ss(Ac, Bc_fir_alt, Cc, Dc_fir_alt);
% % sys_d = mapCtoD(sys_c);
% sys_d = c2d(sys_c,1);
% Ad = sys_d.A; 
% Bd1 = sys_d.B(:,1); Bd2 = sys_d.B(:,2);
% Cd = sys_d.C; Dd = sys_d.D;
% 
% Cfir1 = Cfir(1,:);
% Cfir2 = Cfir(2,:);
% 
% Acomb = [Ad Bd2*Cfir1;
%         zeros(ntaps-1,ord) Afir];
% Bcomb = [Bd1 Bd2*Dfir(1);
%         zeros(ntaps-1,1) Bfir];
% % Ccomb = [Cd zeros(1,ntaps-1)];
% Ccomb = [Cd [Dd(3)*Cfir2]];
% Dcomb = [0 Dd(3)*Dfir(2)];
% ABcomb = [Acomb Bcomb];
% CDcomb = [Ccomb Dcomb];
% 
% ABCDcomb = [ABcomb;CDcomb]

%% Assemble alternative, w/ first order compensation path
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
sys_c = ss(Ac, Bc, Cc, Dc);
% sys_c = ss(Ac, Bc, Cc_fir, Dc);
% sys_d_alt = mapCtoD(sys_c, [[-1 -1];[0 1]]);
% sys_c
sys_d = c2d(sys_c,1,'zoh');
% sys_d
% sys_d_alt
Ad = sys_d.A; 
Bd1 = sys_d.B(:,1); Bd23 = [sys_d.B(:,2)'; [0 0 0 -1]]';
Cd = sys_d.C; 
Dd1 = sys_d.D(1,1); Dd23 = [sys_d.D(1,2)'; 0]';

sizeFirDif = size(Afirdif);
padSize = sizeFirDif(1);
Acomb = [Ad Bd23*Cfirdif;
        zeros(padSize,ord) Afirdif];
Bcomb = [Bd1 Bd23*Dfirdif;
        zeros(padSize,1) Bfirdif];
Ccomb = [Cd Dd23*Cfirdif];
Dcomb = [Dd1 Dd23*Dfirdif];
ABcomb = [Acomb Bcomb];
CDcomb = [Ccomb Dcomb];

ABCDcomb = [ABcomb;CDcomb]

sys_comb = ss(Acomb, Bcomb, Ccomb, Dcomb, 1);
figure;
bode(sys_comb)
title('Bode Plot of combined discrete system')

% Use Matlab to connect systems
Bd = [sys_d.B'; [0 0 0 -1]]'; 
Dd = [sys_d.D'; 0]';
sys_d_2 = ss(sys_d.A, Bd, sys_d.C, Dd, 1);
sys_comb_2 = series(sys_firdif, sys_d_2, [1 2], [2 3]);

% add the missing (main) input u
ABCDcomb = [[sys_comb_2.A [sys_d.B(:,1)' zeros(1,ntaps)]' sys_comb_2.B]; [sys_comb_2.C sys_d.D(:,1) sys_comb_2.D]]



%% Verify impulse response
n_imp = ntaps+5;
tvec = 0:n_imp;
impl_dt_ntf = -impL1(ntf_synth,n_imp);

[Adcomb, Bdcomb, Cdcomb, Ddcomb] = partitionABCD(ABCDcomb);
sys_fir_sim = ss(Adcomb, Bdcomb, Cdcomb, Ddcomb, 1);
impl_fir_sim = -impulse(sys_fir_sim, tvec);
impl_fir_sim = squeeze(impl_fir_sim);


fc_plt = [0 transpose(fc) zeros(1,n_imp-ntaps+1)];
figure;
hold on;
plot(tvec, impl_dt_ntf,'*-','LineWidth',1.2)
plot(tvec, impl_ct(:,2),'o-','LineWidth',1.2)
plot(tvec, impl_ct_tuned(:,2),'o-','LineWidth',1.2)
stem(tvec, fc_plt,'LineWidth',1)
plot(tvec, impl_fir_sim(:,2),'o--','LineWidth',1.2)
xlim([0 n_imp])
%ylim([0 max(impl_dt_ntf)])
set(gca,'FontSize',14)
title('Sampled Loop Filter Impulse Responses','Fontsize', 14)
legend('NTF-Prototype', 'CT-Prototype', 'CT FIR-tuned','Coeff. of Fc(z)','DT-FIR-tuned + Fc(z)','Fontsize', 14)
ylabel('p(t)','Fontsize', 14)
xlabel('t (s)','Fontsize', 14)
grid on;

%% Assemble CIFF-B 
% %ABCD_CIFF_B = [ 0  0  0  0  1 -1;
% %                1  0  0  0  0  0;
% %                0  1  0  0  0  0;
% %                k2 k3 k4 0  0 -k1;
% %                0  0  0  1  0  0];
% [~, ~, Cc, ~] = partitionABCD(ABCD_ct);
% A_ffb = [0 0 0 0; 1 0 0 0; 0 1 0 0; Cc(1,2) Cc(1,3) Cc(1,4) 0];
% B_ffb = [1 -1; 0 0; 0 0; 0 -Cc(1,1)];
% B_ffb_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 -Cc(1,1)];
% C_ffb = [0 0 0 1];
% D_ffb = [0 0];
% D_ffb_fir = [0 0 0];
% 
% AB = [A_ffb B_ffb];
% CD = [C_ffb D_ffb];
% ABCD_ffb = [AB;CD];
% 
% ABCD_ffb_fir = [A_ffb B_ffb_fir;C_ffb D_ffb_fir];
% 
% [~, ~, Cc_tuned, ~] = partitionABCD(ABCD_ct_tuned);
% A_ffb_tuned = [0 0 0 0; 1 0 0 0; 0 1 0 0; Cc_tuned(1,2) Cc_tuned(1,3) Cc_tuned(1,4) 0];
% B_ffb_tuned = [1 -1; 0 0; 0 0; 0 -Cc_tuned(1,1)];
% B_ffb_tuned_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 -Cc_tuned(1,1)];
% C_ffb_tuned = [0 0 0 1];
% D_ffb_tuned = [0 0];
% D_ffb_tuned_fir = [0 0 0];
% 
% ABCD_ffb_tuned = [A_ffb_tuned B_ffb_tuned;C_ffb_tuned D_ffb_tuned];
% ABCD_ffb_tuned_fir = [A_ffb_tuned B_ffb_tuned_fir;C_ffb_tuned D_ffb_tuned_fir];

%% Verify CIFF-B
% [Ac Bc Cc Dc] = partitionABCD(ABCD_ct);
% sys_c = ss(Ac,Bc,Cc,Dc);
% sys_d = mapCtoD(sys_c,tdac2);
% ABCD_ct_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];
% 
% [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ffb);
% sys_c = ss(Ac,Bc,Cc,Dc);
% sys_d = mapCtoD(sys_c,tdac2);
% ABCD_ffb_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];
% 
% [snr1,amp1] = simulateSNR(ABCD_ct_sim, osr);
% [snr2,amp2] = simulateSNR(ABCD_ffb_sim, osr);
% 
% figure;
% hold on;
% plot(amp1, snr1);
% plot(amp1, snr2);
% grid on;

%% Determine coeff. of compensational FIR DAC (CIFF-B)

% Determine pulse response of the prototype loop filter 
% [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ffb_fir);
% sys_ffb = ss( Ac, Bc, Cc, Dc);
% tdac_ffb = [[0 1];[0 1];[0 1]];
% impl_ffb = -pulse(sys_ffb, tdac_ffb, 1, n_imp, 1);
% impl_ffb = squeeze(impl_ffb);
% impl_ffb = impl_ffb(:,2)+impl_ffb(:,3);
% 
% % Determine pulse response of the coefficient-tuned loop filter 
% % with FIR DAC
% [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ffb_tuned_fir);
% Bc(1,2) = -f0;
% sys_ffb_tuned = ss( Ac, Bc, Cc, Dc);
% tdac_ffb_tuned = [[0 1];[0 ntaps];[0 1]];
% impl_ffb_tuned = -pulse(sys_ffb_tuned, tdac_ffb_tuned, 1, n_imp, 1);
% impl_ffb_tuned = squeeze(impl_ffb_tuned);
% impl_ffb_tuned = impl_ffb_tuned(:,2)+impl_ffb_tuned(:,3);
% 
% fc_ffb = abs(impl_ffb(2:ntaps)-impl_ffb_tuned(2:ntaps));
% 
% fc_plt = [0 transpose(fc_ffb) zeros(1,n_imp-ntaps+1)];
% figure;
% hold on;
% plot(tvec, impl_dt_ntf,'*-','LineWidth',1.2)
% plot(tvec, impl_ffb,'o-','LineWidth',1.2)
% plot(tvec, impl_ffb_tuned,'o--','LineWidth',1.2)
% stem(tvec, fc_plt,'LineWidth',1)
% xlim([0 n_imp])
% ylim([0 max(impl_dt_ntf)])
% set(gca,'FontSize',14)
% title('Sampled Loop Filter Impulse Responses (CIFF-B)','Fontsize', 14)
% legend('NTF-Prototype', 'CT-FF-B','CT-FF-B -FIR-tuned','Coeff. of Fc(z)','Fontsize', 14)
% ylabel('p(t)','Fontsize', 14)
% xlabel('t (s)','Fontsize', 14)
% grid on;

% %% FIR DAC State Space Descr. w/ compensation DAC for CIFF-B
% Afir  = sys_fir.A;
% Bfir = sys_fir.B;
% Cfir = [sys_fir.C; 0, transpose(fc(2:3))];
% Dfir = [sys_fir.D; fc(1)];

%% Assemble combined system
% B_ffb_tuned_fir(4,3) = -Cc_tuned(1,1);
% sys_c = ss(A_ffb_tuned, B_ffb_tuned_fir, C_ffb_tuned, D_ffb_tuned_fir);
% % sys_c = ss(Ac, Bc, Cc_fir, Dc);
% % sys_d = mapCtoD(sys_c);
% sys_d = c2d(sys_c,1);
% Ad = sys_d.A; 
% Bd1 = sys_d.B(:,1); Bd23 = sys_d.B(:,2:3);
% Cd = sys_d.C; Dd = sys_d.D;
% Acomb = [Ad Bd23*Cfir;
%         zeros(ntaps-1,ord) Afir];
% Bcomb = [Bd1 Bd23*Dfir;
%         zeros(ntaps-1,1) Bfir];
% Ccomb = [Cd zeros(1,ntaps-1)];
% Dcomb = [0 0];
% ABcomb = [Acomb Bcomb];
% CDcomb = [Ccomb Dcomb];
% 
% ABCDcomb_ffb = [ABcomb;CDcomb]

%% Verify impulse response for CIFF-B

% [Adcomb, Bdcomb, Cdcomb, Ddcomb] = partitionABCD(ABCDcomb_ffb);
% sys_fir_sim = ss(Adcomb, Bdcomb, Cdcomb, Ddcomb, 1);
% impl_fir_sim = -impulse(sys_fir_sim,tvec);
% impl_fir_sim = squeeze(impl_fir_sim);
% 
% figure;
% hold on;
% plot(tvec, impl_dt_ntf,'*-','LineWidth',1.2)
% plot(tvec, impl_ffb,'o-','LineWidth',1.2)
% plot(tvec, impl_ffb_tuned,'o--','LineWidth',1.2)
% stem(tvec, fc_plt,'LineWidth',1)
% plot(tvec, impl_fir_sim(:,2),'o--','LineWidth',1.2)
% % xlim([0 n_imp])
% % ylim([0 max(impl_dt_ntf)])
% set(gca,'FontSize',14)
% title('Sampled Loop Filter Impulse Responses (CIFF-B)','Fontsize', 14)
% legend('NTF-Prototype', 'CT-FF-B','CT-FF-B FIR-tuned','Coeff. of Fc(z)','DT-FIR-tuned + Fc(z)','Fontsize', 14)
% ylabel('p(t)','Fontsize', 14)
% xlabel('t (s)','Fontsize', 14)
% grid on;



%% Simulate, plot and compare
[Ac Bc Cc Dc] = partitionABCD(ABCD_ct);
sys_c = ss(Ac,Bc,Cc,Dc);
sys_d = mapCtoD(sys_c,tdac2);
ABCD_ct_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];

v1 = simulateDSM(u, ABCD_ct_sim, nlev);
% v2= simulateDSM(u, ABCD_ffb_sim, nlev);
v3 = simulateDSM(u, ABCDcomb, nlev);

[SNR1, SNDR1, IBN1, V1, NBW1] = calcPSDParam(v1, N_FFT, fs, fb, fsignal, fres, FS);
% [SNR2, SNDR2, IBN2, V2, NBW2] = calcPSDParam(v2, N_FFT, fs, fb, fsignal, fres, FS);
[SNR3, SNDR3, IBN3, V3, NBW3] = calcPSDParam(v3, N_FFT, fs, fb, fsignal, fres, FS);
plotPSD(V1, NBW1, N_FFT, fres, fb, true);
hold on;
[f,p] = logsmooth(V1,fsignal/fres);
semilogx(f.*fs+fres,p);
% [f,p] = logsmooth(V2,fsignal/fres);
% semilogx(f.*fs+fres,p);
[f,p] = logsmooth(V3,fsignal/fres);
semilogx(f.*fs+fres,p);
legend('CT-FF-Prototype','Band edge (fb)','CT-FF-Prototype (smoothed)','CT-FF FIR+Fc(z) (smoothed)')

figure;
bode(sys_d);
hold on;
bode(sys_fir_sim);
title('Compare Bode Plots of Prototype and Compensated Systems')
legend('Prototype','Compensated')

%% 8.9 Design Example from Bluebook
% 3rd order modulator, OSR=64, OBG=2.5
% Assume NRZ DAC shape

% N = 10;
% ntf = synthesizeNTF(3, 64, 0, 2.5, 0);
% L1 = 1/ntf-1;
% L1 = 1/ntf_synth-1;
% l_1 = impulse(L1,N);
% l_2 = impL1(ntf,N);
% 
% % figure; hold on; stem(l_1); stem(-l_2)
% 
% % Ideal 1st, 2nd and 3rd order paths of the loop filter (s-domain)
% L1_0 = tf([1],[1]);
% L1_1 = tf([1], [1 0]);
% L1_2 = tf([1], [1 0 0]);
% L1_3 = tf([1], [1 0 0 0]);
% L1_4 = tf([1], [1 0 0 0 0]);
% 
% % Ideal impulse responses of 1st, 2nd and 3rd order paths
% x0 = impulse(c2d(L1_0, 1),N);
% x1 = impulse(c2d(L1_1, 1),N);
% x2 = impulse(c2d(L1_2, 1),N);
% x3 = impulse(c2d(L1_3, 1),N);
% x4 = impulse(c2d(L1_4, 1),N);
% % figure; hold on; stem(x0); stem(x1); stem(x2); stem(x3); stem(x4)
% 
% % Determine Coefficients
% K_ol = [x1 x2 x3 x4]\l_1

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
