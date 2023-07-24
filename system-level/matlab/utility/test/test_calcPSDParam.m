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

%% Test SNR and IBN Calc
close all; clear all; clc;
addpath('../../../../python-deltasigma/delsig/')
addpath('../../ctdsm/')
addpath('../')
%%
fin = 0.25;
fs = 1;
%fres = 1/(2.^6);
N = 2.^17;
fb = fs/2;
FS = 2;
amplitude = FS/2;
fres = fs/N;
noise_rms = amplitude./sqrt(2);
in = amplitude*sin(2*pi*(fin/fs)*[1:N]);
in = in+noise_rms*randn(1,length(in));
%plot(in)
[SNR, sndr, IBN, V, NBW, spwr, SNHD3R, fbin, nb, ibncum]= calcPSDParam(in, N, fs, fb, fin, fres, FS);

plotPSD(V, NBW, N, fres, fb, false);

corr = 10*log10(0.5*fs/NBW);
IBN
vn_rms_calc = FS/2/sqrt(2)*10.^(IBN/20)
