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
addpath('/home/koefinger/tools/delsig/delsig/')
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
eld = 0.5; % excess loop delay in units of Ts

%% Stimulus (frequency domain plotting)
fsignal = 18;
n = 0:N_FFT-1;
ampldBFS = -10;
u = (10^(ampldBFS/20))*FS/2*sin(2*pi*fsignal./fs*n);

%% Realize Mod (CT)
ntf_synth = synthesizeNTF(ord, osr, optZ);
ntf_ss = ss(ntf_synth);
[ABCD_ct, tdac2] = realizeNTF_ct(ntf_synth, 'FF', [0 1]+eld);

% create dedicated input for direct path
% if eld >=1 then realizeNTF_ct does this for us
if eld > 0 && eld < 1
    [Act, Bct, Cct, Dct] = partitionABCD(ABCD_ct);
    Bct = [Bct zeros(ord,1)];
    Dct = [0 Dct];
    ABCD_ct = [[Act Bct];[Cct Dct]];
    tdac2 = [tdac2; [0 1]+eld];
end

%% Modify coeff. for use with FIR DAC (Methods of Moments)
ntaps = 4;
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
tf_fir = tf(num_fir, denom_fir,1);
Adc = dcgain(tf_fir);
% tf_fir = tf_fir/Adc; 
sys_fir = ss(tf_fir);

% Bugfix
if ntaps == 2
    sys_fir.C = sys_fir.B;
    sys_fir.B = 1;
end

% Plots
figure; impulse(sys_fir); title('Impulse Response of FIR Filter')
figure; bode(sys_fir); title('Bode Plot of FIR Filter')

%% Determine coeff. of compensational FIR DAC
n_imp = ntaps+5;
impl_dt_ntf = -impL1(ntf_synth,n_imp);

% Determine pulse response of the prototype loop filter
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct);
sys_ct = ss( Ac, Bc, Cc, Dc);
tdac3 = [0 1].*ones(length(Dc),1)+eld;
impl_ct = -pulse(sys_ct, tdac3, 1, n_imp, 1);
impl_ct = squeeze(impl_ct);
impl_ct = impl_ct(:,2:end);
impl_ct_sum = sum(impl_ct,2); % sum v1 and v2 paths in case of direct path

% Determine pulse response of the coefficient-tuned loop filter 
% with FIR DAC
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
Bc(1,2) = -f0;
sys_ct_tuned = ss( Ac, Bc, Cc, Dc);
tdac4 = tdac3; tdac4(2,2) = ntaps+eld;
impl_ct_tuned = -pulse(sys_ct_tuned, tdac4, 1, n_imp, 1);
impl_ct_tuned = squeeze(impl_ct_tuned);
impl_ct_tuned = impl_ct_tuned(:,2);
% impl_ct_tuned_sum = sum(impl_ct_tuned,2); % sum v1 and v2 paths in case of direct path
% impl_ct_tuned_sum = impl_ct_tuned(:,1);
% Calc difference for first ntaps samples
fc = impl_ct_sum-impl_ct_tuned;
fc(fc<1e-10)=0;
fc_plt = fc;
fc = nonzeros(fc)

% Plot
tvec = 0:n_imp;
figure;
hold on;
plot(tvec, impl_dt_ntf,'*-','LineWidth',1)
plot(tvec, impl_ct_sum,'o-','LineWidth',1)
plot(tvec, impl_ct_tuned,'o-','LineWidth',1)
stem(tvec, fc_plt)
% plot(yy2(:,1,2),'o-')
% xlim([0 n_imp])
ylim([0 max(impl_dt_ntf)])
set(gca,'FontSize',14)
title('Sampled Loop Filter Impulse Responses','Fontsize', 14)
legend('NTF-Prototype', 'CT-Prototype', 'CT FIR-tuned','Coeff. of Fc(z)','Fontsize', 14)
ylabel('p(t)','Fontsize', 14)
xlabel('t in s','Fontsize', 14)
grid on;

%% Add direct path input to state space description of CT prototype
[Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
Bc_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 0];
Dc_fir = [0 0 -1];
% Bc_fir = [1 -1 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0];
% Dc_fir = [0 0 -1 Dc(3)];

%% FIR DAC State Space Descr. w/ compensation DAC
Afir  = sys_fir.A;
%Bfir = ss_fir.B./ss_fir.B(1);
Bfir = sys_fir.B;
% Cfir = [ss_fir.C.*ss_fir.B(1); ss_fir.C.*ss_fir.B(1)];
if length(fc) < ntaps
    Cfir = [sys_fir.C; fc'];
    Dfir = [sys_fir.D; 0];
elseif length(fc) == ntaps
    % direct path requiered
    Cfir = [sys_fir.C; fc(2:end)'];
    Dfir = [sys_fir.D; fc(1)];
else
    error("too many compensation coefficients");
end
sys_fir_simo = ss(Afir, Bfir, Cfir, Dfir, 1);
figure; impulse(sys_fir_simo); title('Impulse Response of F(z) and Fc(z)')
figure; bode(sys_fir_simo); title('Bode Plot of F(z) + Fc(z)')

%% Assemble combined system
% INFO: [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
sys_c = ss(Ac, Bc_fir, Cc, Dc_fir);
sys_d = c2d(sys_c,1, 'zoh');

Ad = sys_d.A; 
Bd1 = sys_d.B(:,1); Bd23 = [sys_d.B(:,2)'; [0 0 0 0]]';
Cd = sys_d.C; 
Dd1 = sys_d.D(1,1); Dd23 = [sys_d.D(1,2)'; -1]';

Acomb = [Ad Bd23*Cfir;
        zeros(ntaps-1,ord) Afir]
Bcomb = [Bd1 Bd23*Dfir;
        zeros(ntaps-1,1) Bfir]
% Bcomb = [Bcomb zeros(ord+ntaps-1,1)]
Ccomb = [Cd Dd23*Cfir]
Dcomb = [Dd1 Dd23*Dfir]
% Dcomb = [Dd1 Dd23*Dfir sys_d.D(1,4)]
ABcomb = [Acomb Bcomb];
CDcomb = [Ccomb Dcomb];

ABCDcomb = [ABcomb;CDcomb]

%% Verify impulse response
n_imp = ntaps+5;
tvec = 0:n_imp;
impl_dt_ntf = -impL1(ntf_synth,n_imp);

[Adcomb, Bdcomb, Cdcomb, Ddcomb] = partitionABCD(ABCDcomb);

% Convert discrete time system into Matlab SS model and use Matlab function
% to calculate the impulse response
sys_fir_sim = ss(Adcomb, Bdcomb, Cdcomb, Ddcomb,1);
impl_fir_sim = -impulse(sys_fir_sim,tvec);
impl_fir_sim = squeeze(impl_fir_sim);
impl_fir_sim = [zeros(1,ceil(eld)); impl_fir_sim(1:end-ceil(eld),2)];

% GIVES WRONG RESULTS, 'tustin' is probably the wrong method, but 'zoh' is
% not allowed here?!
% Convert discrete time Matlab SS model into a continuous time model
% and use delsig toolbox to calculate the impulse response
% sys_fir_sim_ct = d2c(sys_fir_sim, "tustin");
% tdac5 = [0 1].*ones(length(Ddcomb),1)+eld;
% impl_fir_sim_ct = -pulse(sys_fir_sim_ct,tdac5, 1, n_imp, 1);
% impl_fir_sim_ct = impl_fir_sim_ct(:,2);

figure;
hold on;
plot(tvec, impl_dt_ntf,'*-','LineWidth',1.2)
plot(tvec, impl_ct_sum,'o-','LineWidth',1.2)
plot(tvec, impl_ct_tuned,'o-','LineWidth',1.2)
stem(tvec, fc_plt,'LineWidth',1)
plot(tvec, impl_fir_sim,'o--','LineWidth',1.2)
% plot(tvec, impl_fir_sim_ct+abs(impl_fir_sim_ct(1)),'*--','LineWidth',1.2)
xlim([0 n_imp])
ylim([0 max(impl_dt_ntf)])
set(gca,'FontSize',14)
title('Sampled Loop Filter Impulse Responses','Fontsize', 14)
legend('NTF-Prototype', 'CT-Prototype', 'CT FIR-tuned','Coeff. of Fc(z)','DT-FIR-tuned + Fc(z)','Fontsize', 14)
ylabel('$p(t)$ (1)','Fontsize', 14, 'Interpreter', 'Latex')
xlabel('$t$ (s)','Fontsize', 14, 'Interpreter', 'Latex')
grid on;


%% Simulate, plot and compare
[Ac_prot Bc_prot Cc_prot Dc_prot] = partitionABCD(ABCD_ct);
sys_c = ss(Ac_prot,Bc_prot,Cc_prot,Dc_prot);
sys_d = mapCtoD(sys_c,tdac2);
ABCD_ct_sim = [sys_d.a sys_d.b; sys_d.c sys_d.d];

v1 = simulateDSM(u, ABCD_ct_sim, nlev);
% v2= simulateDSM(u, ABCD_ffb_sim, nlev);
[v3,xn3,xmax3,y3] = simulateDSM(u, ABCDcomb, nlev);
plotInternalSignals(1, fsignal, 1, [xn3(1,:); xn3(2,:); xn3(3,:); xn3(4,:)], ["Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], false)
xlim = xmax3;
xlim(1:4) = 2.*[0.6 1 1 1];
[ABCDcomb_scaled, umax, Tscale] = scaleABCD(ABCDcomb, 2, 0, xlim');
msa = 20*log10(umax/(FS/2));
[v4,xn4,xmax4,y4] = simulateDSM(u, ABCDcomb_scaled, nlev);
plotInternalSignals(1, fsignal, 1, [xn4(1,:); xn4(2,:); xn4(3,:); xn4(4,:)], ["Output Int. 1", "Output Int. 2", "Output Int. 3", "Output Int. 4"], false)

[SNR1, SNDR1, IBN1, V1, NBW1] = calcPSDParam(v1, N_FFT, fs, fb, fsignal, fres, FS);
% [SNR2, SNDR2, IBN2, V2, NBW2] = calcPSDParam(v2, N_FFT, fs, fb, fsignal, fres, FS);
[SNR3, SNDR3, IBN3, V3, NBW3] = calcPSDParam(v3, N_FFT, fs, fb, fsignal, fres, FS);
[SNR4, SNDR4, IBN4, V4, NBW4] = calcPSDParam(v4, N_FFT, fs, fb, fsignal, fres, FS);
plotPSD(V1, NBW1, N_FFT, fres, fb, true);
hold on;
[f,p] = logsmooth(V1,fsignal/fres);
semilogx(f.*fs+fres,p);
% [f,p] = logsmooth(V2,fsignal/fres);
% semilogx(f.*fs+fres,p);
[f,p] = logsmooth(V3,fsignal/fres);
semilogx(f.*fs+fres,p);
[f,p] = logsmooth(V4,fsignal/fres);
semilogx(f.*fs+fres,p);
legend('CT-FF-Prototype','Band edge (fb)','CT-FF-Prototype (smoothed)','CT-FF FIR+Fc(z) (smoothed)','CT-FF FIR+Fc(z) scaled (smoothed)')

figure;
bode(sys_d);
hold on;
bode(sys_fir_sim);
title('Compare Bode Plots of Prototype and Compensated Systems')
legend('Prototype','Compensated')

%% Extract scaled unity gain frequencies and feed forward coefficients
[Ads, Bds, Cds, Dds] = partitionABCD(ABCDcomb_scaled);
Ad_scaled = Ads(1:ord,1:ord);
Bd_scaled = Bds(1:ord,1:2);
Bd_scaled(1,2) = -Bd_scaled(1,1);
Cd_scaled = Cds(1:ord);
Dd_scaled = [0 0];

ABCDd_scaled = [Ad_scaled Bd_scaled; Cd_scaled Dd_scaled];
sys_d_scaled = ss(Ad_scaled, Bd_scaled, Cd_scaled, Dd_scaled, 1);
sys_c_scaled = d2c(sys_d_scaled,'zoh');
sys_c_scaled.A(abs(sys_c_scaled.A)<1e-10) = 0;
sys_c_scaled.B(abs(sys_c_scaled.B)<0.09) = 0;
k_scaled = [sys_c_scaled.B(1,1) sys_c_scaled.A(2,1) sys_c_scaled.A(3,2) sys_c_scaled.A(4,3)]
sys_c_scaled.C
xmax4
