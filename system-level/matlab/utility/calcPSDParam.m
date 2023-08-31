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

% [20] S. Pavan, R. Schreier, and G. Temes. "Spectral Estimation". In: Understanding
% Delta-Sigma Data Converters. Hoboken, N.J.: Wiley-IEEE Press, 2017, pp. 483–498.

% [24] M. Ortmanns and F. Gerfers. "Program Code". In: Continuous-Time Sigma-
% Delta A/D Conversion. Fundamentals, Performance Limits and Robust Imple-
% mentations. Springer Series in Advanced Microelectronics. Heidelberg, Berlin:
% Springer, 2006, pp. 213–214. 

% Calculate all parameters from the FFT of the DSM's digizited output
function [snr, sndr, ibn, V, NBW, spwr, snhd3r, fbin, nb, ibn_cum, HD3, hd3pwr] = calcPSDParam(y, N, fs, fb, fsig, fres, FS, finter, searchBins)
    if nargin < 9
        addBins = 10;
    else
        addBins = searchBins;
    end

    %w = blackmanharris(N);         % blackmanharris window --> spreads signal power into 7 bins
    w = hann(N);
    %nb = 7;                        % blackmanharris   
    nb = 3;
    w1 = norm(w,1);
    w2 = norm(w,2);
    NBW = (w2/w1).^2;            % noise bandwidth
    ampl_scale = FS/4;
    V = fft(w'.*y)/(ampl_scale)/w1;       % sinewave scaling --> FS gives 0dB
    fbin = round(fsig/fres);        % fin*N/fs;
    
    nb_leak = 1;
    if addBins > 0
        % find approx. number of signal bins due to leakage [24]
        comp = abs(V(fbin));    
        bins = (fbin+nb_leak):(fbin+nb_leak+addBins);
        while(min(abs(V(bins)))<comp)
            comp = abs(V(fbin+nb_leak));
            nb_leak = nb_leak+addBins;
            bins = (fbin+nb_leak):(fbin+nb_leak+1);
        end
    end

    dc_bins = 0:(nb-1)/2;
%   dc_bins = 0:ceil(1.5./fres);    % exclude if fres is too small
    if nb_leak < nb-1
        signal_bins = fbin-(nb-1)/2:fbin+(nb-1)/2;
    else
        signal_bins = fbin-(nb_leak-1):fbin+(nb_leak-1);
    end
    hd2 = fbin*2;
    hd3 = fbin*3;
    hd2_bins = hd2-(nb-1)/2:hd2+(nb-1)/2;
    hd3_bins = hd3-(nb-1)/2:hd3+(nb-1)/2;
    inband_bins = 0:fb/fres;
    
    % check if interferer frequency was given as input argument
    if nargin >= 8
        % exclude interferer bins from SNR calculations
        finterbin = round(finter/fres);
        inter_bins = finterbin-(nb-1)/2:finterbin+(nb-1)/2;
        noise_bins_sndr = setdiff(inband_bins, [dc_bins, signal_bins, inter_bins]);
        noise_bins_snr = setdiff(inband_bins, [dc_bins, signal_bins, hd2_bins, hd3_bins, inter_bins]);
        noise_bins_snhd3r = setdiff(inband_bins, [dc_bins, signal_bins, hd2_bins, inter_bins]);
    else
        noise_bins_sndr = setdiff(inband_bins, [dc_bins, signal_bins]);
        noise_bins_snr = setdiff(inband_bins, [dc_bins, signal_bins, hd2_bins, hd3_bins]);
        noise_bins_snhd3r = setdiff(inband_bins, [dc_bins, signal_bins, hd2_bins]);
    end
    spwr = sum(abs(V(signal_bins+1)).^2);
    hd3pwr = sum(abs(V(hd3_bins+1)).^2);
    npwr_sndr = sum(abs(V(noise_bins_sndr+1)).^2);
    npwr_snhd3r = sum(abs(V(noise_bins_snhd3r+1)).^2);
    npwr_snr = sum(abs(V(noise_bins_snr+1)).^2);
    HD3 = sqrt(hd3pwr)/sqrt(spwr);

    % calc cummualted inband noise vector
    Vnoise = V(inband_bins+1);
    Vnoise(signal_bins+1) = 0;
    Vnoise(dc_bins+1) = 0;
    Vnoise(hd2_bins+1) = 0;
    Vnoise(hd3_bins+1) = 0;
    ibn_cum = cumsum((abs(Vnoise)).^2)./NBW./N;
    
    snr = 10*log10(spwr/npwr_snr);
    sndr = 10*log10(spwr/npwr_sndr);
    snhd3r = 10*log10(spwr/npwr_snhd3r);
    ibn = 10*log10(ibn_cum(end));
    spwr = 10*log10(spwr);   

end