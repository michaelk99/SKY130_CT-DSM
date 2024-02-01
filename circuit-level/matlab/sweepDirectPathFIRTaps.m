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
addpath('/home/michael/tools/delsig/delsig/')
addpath('../../system-level/matlab/utility/')
%% Specs
kB = 1.38e-23;
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

% Modulator specs
ord = 4;
k = 1.0;
nlev = 2;
optZ = 0;
topo = 'CIFF';
osr = 256;                  
fres = 1/64;                    
M = nlev -1;
delta = 2;
FS = 2*(M/2*delta);
N_FFT = ceil(fs/fres);
fsignal = 18;
n = 0:N_FFT-1;
xMaxDesFF = [0.5 0.5 0.5 0.5];

%% Realize Mod (CT)
ntf_synth = synthesizeNTF(ord, osr, optZ);
ntf_ss = ss(ntf_synth);
[ABCD_ct, tdac2] = realizeNTF_ct(ntf_synth, 'FF');

%% Sweep FIR filter taps

ntapsVec = 4:20;
nSweeps = length(ntapsVec);

IBNVec = zeros(1,length(nSweeps));
MSIVec = zeros(1,length(nSweeps));
CAreaVec = zeros(1,length(nSweeps));
RAreaVec = zeros(1,length(nSweeps));
AreaPassiveVec = zeros(1,length(nSweeps));

for i=1:nSweeps
   
    % Tune filter coeff 
    ntaps = ntapsVec(i);
    [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct);
    c4_fir = Cc(4);
    c3_fir = Cc(3)+(Cc(4)*(ntaps-1))/2;
    c2_fir = Cc(2)+(6*Cc(3)*(ntaps-1)+Cc(4)*(ntaps.^2-3*ntaps+2))/12;
    c1_fir = Cc(1)+(12*Cc(2)*(ntaps-1)+2*Cc(3)*(ntaps.^2-3*ntaps+2)-Cc(4)*(ntaps.^2-2*ntaps+1))/24;
    Cc_fir = [c1_fir c2_fir c3_fir c4_fir];
    ABCD_ct_tuned = [[Ac Bc];[Cc_fir Dc]];

    % FIR DAC State Space Descr.
    f0 = 1/(ntaps);
    num_fir = f0.*ones(1,ntaps);
    denom_fir = zeros(1,ntaps);
    denom_fir(1) = 1;
    tf_fir = tf(num_fir, denom_fir,1);
    sys_fir = ss(tf_fir);

    % Determine coeff. of compensational FIR DAC
    n_imp = ntaps+5;
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

    % Add direct path input to state space description of CT prototype
    [Ac, Bc, Cc, Dc] = partitionABCD(ABCD_ct_tuned);
    Bc_fir = [1 -1 0; 0 0 0; 0 0 0; 0 0 0];
    Dc_fir = [0 0 -1];

    % FIR DAC State Space Descr. w/ compensation DAC
    Afir  = sys_fir.A;
    Bfir = sys_fir.B;
    Cfir = [sys_fir.C; fc'];
    Dfir = [sys_fir.D; 0];

    % Assemble combined system
    sys_c = ss(Ac, Bc_fir, Cc, Dc_fir);
    % sys_d = mapCtoD(sys_c);
    sys_d = c2d(sys_c,1);
    Ad = sys_d.A; 
    Bd1 = sys_d.B(:,1); Bd2 = sys_d.B(:,2);
    Cd = sys_d.C; Dd = sys_d.D;
    Cfir1 = Cfir(1,:);
    Cfir2 = Cfir(2,:);
    Acomb = [Ad Bd2*Cfir1;
            zeros(ntaps-1,ord) Afir];
    Bcomb = [Bd1 Bd2*Dfir(1);
            zeros(ntaps-1,1) Bfir];
    Ccomb = [Cd [Dd(3)*Cfir2]];
    Dcomb = [0 Dd(3)*Dfir(2)];
    ABcomb = [Acomb Bcomb];
    CDcomb = [Ccomb Dcomb];
    ABCDcomb = [ABcomb;CDcomb];

    % Perform state scaling
    xlim = ones(1,ord+ntaps-1);
    xlim(1:4) = 2.*xMaxDesFF;
    [ABCDcomb_scaled, umax] = scaleABCD(ABCDcomb, 2, 0, xlim);
    MSIVec(i) = 20*log10(umax/(FS/2));
    % Determine IBN
    ampldBFS = MSIVec(i)-10;
    u = (10^(ampldBFS/20))*FS/2*sin(2*pi*fsignal./fs*n);
    [v4] = simulateDSM(u, ABCDcomb_scaled, nlev);
    [~, ~, IBNVec(i)] = calcPSDParam(v4, N_FFT, fs, fb, fsignal, fres, FS);
    

    % Extract scaled unity gain frequencies and feed forward coefficients
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
    kFF = [sys_c_scaled.B(1,1) sys_c_scaled.A(2,1) sys_c_scaled.A(3,2) sys_c_scaled.A(4,3)];
    CFFss = sys_c_scaled.C;
    fugFF = fs.*kFF;

    %System Sim Results
    VnoiseBudgetVecFF = [1 47 300 600].*1e-6;
    VoppVecFF = xMaxDesFF;
    ADCVecFF_dB = [45 45 45 25];
    ADCVecFF = 10.^(ADCVecFF_dB/20);
    
    PbudgetVecFF = [Ptot P24./2  P24./4 P24./4];
    IBiasStageFF = PbudgetVecFF./Vdd;
    IoutStageFF = IBiasStageFF./4;
    
    %Minimum Rin for Stages 2 - 4
    RVecMinFF = VoppVecFF(1:end-1)./2./IoutStageFF(1:end-1);
    RVecMinFFMeg = RVecMinFF/1e6;
    
    %Single Stage OTA Specs: gm, Ro for Stages 2 - 4
    GmOTAVecFF = gmIdMax.*IoutStageFF(2:4);
    GmOTAVecFFuS = GmOTAVecFF./1e-6;
    RoOTAVecFF = ADCVecFF(2:4)./GmOTAVecFF;
    RoOTAVecFFMOhm = RoOTAVecFF./1e6;
    
    %RC - OTA Integrators 
    
    CVecFF = 1./(fugFF(2:4).*RVecMinFF);
    CVecFF(3) = CVecFF(3)/CFFss(4);
    CVecFFpF = CVecFF./1e-12;
    
    %FF Coeff
    CFFVec = CFFss(1:3).*CVecFF(3);
    CFFVecpF = CFFVec./1e-12;
    
    %Noise Budget OTA for Stages 2 - 4: FF
    Vnoise_Rin_in_rms_Vec_FF = sqrt(8.*k.*T.*RVecMinFF.*fb);
    
    Vnoise_DAC_in_rms_Vec_FF = zeros(1,length(RVecMinFF));
    Vnoise_Amp_in_rms_Vec_FF = sqrt(VnoiseBudgetVecFF(2:end).^2-Vnoise_Rin_in_rms_Vec_FF.^2-Vnoise_DAC_in_rms_Vec_FF.^2);
    Vnoise_Amp_rms_1_Vec_FF = Vnoise_Amp_in_rms_Vec_FF;
    Vnoise_Amp_rms_1_Vec_FFuV = Vnoise_Amp_rms_1_Vec_FF./1e-6;
    Vnoise_Amp_rms_1_Vec_gm_approx_FF = sqrt(8*kB*T./GmOTAVecFF.*gammaMOS);
    NEF_Vec_FF = Vnoise_Amp_rms_1_Vec_FF.^2./(Vnoise_Amp_rms_1_Vec_gm_approx_FF.^2);
    
    % 1. Stage
    Vnoise_in_density = sqrt(VnoiseBudgetVecFF(1).^2./fb);
    xRs = 1/4;
    xAmp = 1/2;
    Vnoise_Rs_in = xRs.*Vnoise_in_density.^2;
    Vnoise_CS_in = xRs.*Vnoise_in_density.^2;
    R1max = Vnoise_Rs_in./(8*kB*T);
    R1maxkOhm = R1max./1e3;
    R1 = 50e3;
    Ibias1 = Vin_peak_max./2/R1;
    R1DAC = R1;
    Gmeff = 1/R1;
    Inoise_CS_rms = sqrt(Vnoise_CS_in*Gmeff.^2);
    Vnoise_Rs_in_rms = sqrt(8*kB*T*R1);
    Vnoise_RDAC_in_rms = sqrt(8*kB*T*R1.^2/R1DAC);
    Vnoise_CS_in_rms = sqrt(Vnoise_CS_in);
    Vnoise_Ampboost_in_rms = sqrt(0.5*(Vnoise_in_density.^2-Vnoise_Rs_in_rms.^2-Vnoise_RDAC_in_rms.^2-Vnoise_CS_in));
    
    C1FF = 1./(fugFF(1)*R1)/2; % Half it as wug is defined by Gmeff/2
    
    Ro1FF = ADCVecFF(1)./Gmeff;
    Ro1FFMOhm = Ro1FF./1e6;
    
    % Total Res and Cap for FB and FF
    CtotFF = C1FF+2*sum(CVecFF)+2*sum(CFFVec);
    RtotFF = 2*R1+2*R1DAC+2*sum(RVecMinFF);
    
    % Area of Caps and Res: FB and FF
    W_rpoly = 0.35e-6;
    Rsheet = 2000; % 2kOhm pro sq
    CpArea = 4e-15/1e-12; % 5fF pro um^2
    L_RtotFF = RtotFF.*W_rpoly/Rsheet; 
    A_RtotFF = L_RtotFF.*W_rpoly;
    A_RtotFF_mmsq = A_RtotFF./1e-6;
    A_CtotFF = CtotFF./CpArea;
    A_CtotFF_mmsq = A_CtotFF./1e-6;
    A_RC_FF = A_RtotFF+A_CtotFF;
    A_RC_FF_mmsq = A_RC_FF./1e-6;

    CAreaVec(i) = A_CtotFF_mmsq;
    RAreaVec(i) = A_RtotFF_mmsq;
    AreaPassiveVec(i) = A_RC_FF_mmsq;
end

figure;
subplot(5, 1, 1);
plot(ntapsVec, IBNVec, '-o');
ylabel('Total Inband Noise (dBFS)')
xlabel('n-taps')
grid on;

subplot(5, 1, 2);
plot(ntapsVec, MSIVec, '-o');
ylabel('Max. Stable Input Amplitude (dBFS)')
xlabel('n-taps')
grid on;

subplot(5, 1, 3);
plot(ntapsVec, CAreaVec, '-o');
ylabel('Cap. Area Est. (mmsq)')
xlabel('n-taps')
grid on;

subplot(5, 1, 4);
plot(ntapsVec, RAreaVec, '-o');
ylabel('Res. Area Est. (mmsq)')
xlabel('n-taps')
grid on;

subplot(5, 1, 5);
plot(ntapsVec, AreaPassiveVec, '-o');
ylabel('RC Area Est. (mmsq)')
xlabel('n-taps')
grid on;




