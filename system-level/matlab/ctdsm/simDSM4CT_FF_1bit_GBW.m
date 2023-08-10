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

function [y, fs, N, w1, w2, w3, w4, wsum] = simDSM4CT_FF_1bit_GBW(OSR, ctSteps, fb, fin, fres, amplitude, offset, omCoeff, cCoeff, Vref, noiseVec_rms, wLimVec, cVec, optNoiseVec)
% Simulate a 4th order CT DSM (Coeff: cCoeff (Feedforward), omCoeff (integrator unity-gain frequencies in units of the sampling frequency fs)
% OSR ... oversampling ratio
% ctSteps ... integrator oversampling ratio to simulate CT
% fb ... max. signal frequency
% fres ... FFT frequency resolution
% fin ... frequency of stimulus
% amplitude ... amplitude of stimulus
% offset ... dc component of stimulus
% Vref ... Half the input full-scale of the internal 2-bit quantizer
% wLimVec ... Integrator output limiter
% cVec ... second pole of the ITF in units of fs

% Modulator Non-Idealities
% 1. Thermal Noise (noiseVec_rms, optNoiseVec)
% 2. Second integrator pole

% Define input sinewave and sampling conditions
fs = OSR*2*fb;

N          = ceil(fs/fres);
nr_periods = ceil(fin/fres);
nr_steps   = ctSteps; % number of simulations steps per sample period

Vref_p = Vref;
Vref_n = -Vref;

% Thermo DAC elements (4-level)
elements = ones(1,1);

% ****************************************
% DAC Waveforms
% ****************************************
% Defining DAC feedback signals with symmetrical rise and fall times
DAC_wave(1,(1:nr_steps)) = Vref_p.*ones(1,nr_steps);

% ****************************************
% Allocate Arrays
% ****************************************
% Pre-allocate and initialize array variables => faster code
in = offset+amplitude*sin(2*pi*(fin/fs)*[1:N*nr_steps]/nr_steps);
y  = zeros(1,N*nr_steps); wsum = y;
y(1:nr_steps) = 1;              % set y(1)
y(nr_steps+1:2*nr_steps) = 1;   % set y(2)
y(2*nr_steps+1:3*nr_steps) = 1; % set y(3)
w1 = zeros(1,N*nr_steps); w2 = w1; w3 = w1; w4 = w1; 

DAC = y;

b1 = 1;

k1 = cCoeff(1);
k2 = cCoeff(2);
k3 = cCoeff(3);
k4 = cCoeff(4);

% Adjust coefficients to account for simulation step-size, 
% with limited DC gain of the intergrators
omega1 = omCoeff(1)/(fs*nr_steps);
omega2 = omCoeff(2)/(fs*nr_steps);
omega3 = omCoeff(3)/(fs*nr_steps);
omega4 = omCoeff(4)/(fs*nr_steps);

% Impulse response of ideal integrator with additional pole
tx = 1:nr_steps*2;
impulse_response_1(1:nr_steps*2)=1-exp(-tx*cVec(1)/nr_steps);
impulse_response_2(1:nr_steps*2)=1-exp(-tx*cVec(2)/nr_steps);
impulse_response_3(1:nr_steps*2)=1-exp(-tx*cVec(3)/nr_steps);
impulse_response_4(1:nr_steps*2)=1-exp(-tx*cVec(4)/nr_steps);

integ_filter_1=flipud(diff([0,impulse_response_1])');
integ_filter_2=flipud(diff([0,impulse_response_2])');
integ_filter_3=flipud(diff([0,impulse_response_3])');
integ_filter_4=flipud(diff([0,impulse_response_4])');


if optNoiseVec(4) == false
    noiseVec_rms(4) = 0;
end
if optNoiseVec(3) == false
    noiseVec_rms(3) = 0;
end
if optNoiseVec(2) == false
    noiseVec_rms(2) = 0;
end
if optNoiseVec(1) == false
    noiseVec_rms(1) = 0;
end


ix = nr_steps*2+1;     
for a = 3:N
    for b = 1:nr_steps
        ix = ix+1;
        idx1 = ix-nr_steps*2;
        idx2 = ix-1;
        w4(ix) = w4(ix-1) + omega4*(    w3(idx1:idx2) + noiseVec_rms(4)*randn()*sqrt(nr_steps) ) *integ_filter_4;
        w3(ix) = w3(ix-1) + omega3*(    w2(idx1:idx2) + noiseVec_rms(3)*randn()*sqrt(nr_steps) ) *integ_filter_3;
        w2(ix) = w2(ix-1) + omega2*(    w1(idx1:idx2) + noiseVec_rms(2)*randn()*sqrt(nr_steps) ) *integ_filter_2;
        w1(ix) = w1(ix-1) + omega1*( b1*in(idx1:idx2) - b1*DAC(idx1:idx2)   + noiseVec_rms(1)*randn()*sqrt(nr_steps) ) *integ_filter_1;
                
        % Limiter
        if w1(ix) > wLimVec(1)
            w1(ix) = wLimVec(1);
        elseif w1(ix) < -wLimVec(1)
            w1(ix) = -wLimVec(1);
        end
        if w2(ix) > wLimVec(2)
            w2(ix) = wLimVec(2);
        elseif w2(ix) < -wLimVec(2)
            w2(ix) = -wLimVec(2);
        end
        if w3(ix) > wLimVec(3)
            w3(ix) = wLimVec(3);
        elseif w3(ix) < -wLimVec(3)
            w3(ix) = -wLimVec(3);
        end
        if w4(ix) > wLimVec(4)
            w4(ix) = wLimVec(4);
        elseif w4(ix) < -wLimVec(4)
            w4(ix) = -wLimVec(4);
        end
    end

    wsum(a) = w1(ix)*k1+w2(ix)*k2+w3(ix)*k3+w4(ix)*k4;
    
    % 2-bit mid-rise DAC
    [y(ix+1:ix+nr_steps), thermoCode] = mbq(wsum(a), 2, Vref);
    
    dacVal = Vref.*thermoDAC(thermoCode, elements, 2, false);
    DAC(ix+1:ix+nr_steps) = dacVal;
    
end
    y = downsample(y,nr_steps);
    y = y(3:end);
end