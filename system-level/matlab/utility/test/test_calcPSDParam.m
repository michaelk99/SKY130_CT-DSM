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
%% Sine
close all;
fin = 18;
fs = 2.^16;
%fres = 1/(2.^6);
nlev = 4;
vref = 0.36;
N = 2.^17;
fb = 128;
FS = nlev;
amplitude = vref;
fres = fs/N;
vlsb = 2*vref/nlev;
in = amplitude*sin(2*pi*(fin/fs)*[1:N]);
p_in = (amplitude/sqrt(2)).^2;
[out, thermo] = mbq(in, nlev, vref);
 
figure;
plot(in,out)
title('mbq() Test - Sine Input - Vector')
grid on;
%plot(in)

fsig = fin;
y=out;
% calcPSDParam
addBins = 1;

%w = blackmanharris(N);         % blackmanharris window --> spreads signal power into 7 bins
w = hann(N);
% w= ones(N,1);
%nb = 7;                        % blackmanharris   
nb = 3;
% nb = 1;
w1 = norm(w,1);
w2 = norm(w,2);
NBW = (w2/w1).^2;            % noise bandwidth
ampl_ref = (FS)/2;
ampl_scale = ampl_ref/2;
V = fft(w'.*y)/(ampl_scale)/w1;       % sinewave scaling --> FS gives 0dB
ys = abs(fft(w'.*y)).^2;
psdy = ys*NBW/fres;
fbin = round(fsig/fres);        % fin*N/fs;

signal_bins = fbin-(nb-1)/2:fbin+(nb-1)/2;
inband_bins = 0:fb/fres;

p_ref = (ampl_ref/sqrt(2)).^2;
% spwr = sum(abs(V(signal_bins+1)).^2)*p_ref;
spwr = sum(abs(V(signal_bins+1)).^2);

%spwr = 10*log10(spwr);   

plotPSD(V, NBW, N, fres, fb, true);

[SNR, sndr, IBN, V2, NBW2, spwr, SNHD3R, fbin, nb, ibncum]= calcPSDParam(in, N, fs, fb, fin, fres, 2*vref, 0, 0);
plotPSD(V2, NBW2, N, fres, fb, true);
spwr
p_in
ampl_plot_dBFS = 10*log10(abs(V(fbin+1)).^2)
ampl_plot = vref*10.^(ampl_plot_dBFS/20)

%% Noise
fin = 0.25;
fs = 1;
%fres = 1/(2.^6);
N = 2.^17;
fb = fs/2;
FS = 2;
amplitude = FS/2;
fres = fs/N;
noise_rms = amplitude;
in = noise_rms*randn(1,N);
%plot(in)
%[SNR, sndr, IBN, V, NBW, spwr, SNHD3R, fbin, nb, ibncum]= calcPSDParam(in, N, fs, fb, fin, fres, FS);
fsig=fin;
y=in;
% calcPSDParam
addBins = 10;

% w = blackmanharris(N);         % blackmanharris window --> spreads signal power into 7 bins
w = hann(N);
% w = ones(N,1);
% nb = 7;                        % blackmanharris   
nb_hann = 3;
% nb = 1;
w1 = norm(w,1);
w2 = norm(w,2);
NBW = (w2/w1).^2;            % noise bandwidth
ampl_ref = FS/2;
ampl_scale = ampl_ref/2;
V = fft(w'.*y)./(ampl_scale)./w1;       % sinewave scaling --> FS gives 0dB
V2 = fft(w'.*y)./w1;       % sinewave scaling --> FS gives 0dB
fbin = round(fsig/fres);        % fin*N/fs;

inband_bins = 0:fb/fres;

% calc cummualted inband noise vector
Vnoise = V;
% Vnoise(signal_bins+1) = 0;
% Vnoise(dc_bins+1) = 0;
ibn_cum = 2*cumsum((abs(Vnoise(inband_bins+1))).^2)/NBW/N;

% sndr = 10*log10(spwr/npwr_sndr);
ibn = 10*log10(ibn_cum(end));
% spwr = 10*log10(spwr);   
plotPSD(V2, NBW, N, fres, fb, false);

ibn
vn_rms_calc = ampl_scale*10.^(ibn/20)
noise_rms

%%
% win = ones(1,N);
win = hann(N)';
W = fft(win);
W0 = abs(W(1));
w_max_norm = norm(win,1);
in = amplitude*sin(2*pi*(fin/fs)*[1:N]);
Vin = fft(win.*in);
figure;
stem(in);

figure;
plot(abs(Vin).^2)

figure;
plot((abs(Vin)/W0).^2)

figure;
plot((abs(Vin)/(W0*amplitude/2)).^2)