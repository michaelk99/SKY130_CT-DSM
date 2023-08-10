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

function [y, fs, N, w1, w2, w3, w4, wsum, w1_in] = simDSM4CT_FF_1bit_nonlin(OSR, ctSteps, fb, fin, fres, amplitude, offset, amplitude_inter, finter, omCoeff, cCoeff, Vref, A0Vec, eld, noiseVec_rms, wLimVec, g3, optNoiseVec, optLeakyInt, optDACMismatch, optDAC)
% Simulate a 4th order CT DSM (Coeff: cCoeff (Feedforward), omCoeff (integrator unity-gain frequencies in units of the sampling frequency fs)
% OSR ... oversampling ratio
% ctSteps ... integrator oversampling ratio to simulate CT
% fb ... max. signal frequency
% fres ... FFT frequency resolution
% fin ... frequency of stimulus
% amplitude ... amplitude of stimulus
% offset ... dc component of stimulus
% amplitude_inter ... amplitude of an interferer, set to 0 if not used
% finter ... frequency of the interferer
% Vref ... Half the input full-scale of the internal 2-bit quantizer
% wLimVec ... Integrator output limiter

% Modulator Non-Idealities
% 1. Limited integrator gain (A0Vec, optLeakyInt)
% 2. Excess Loop Delay (eld)
% 3. Thermal Noise (noiseVec_rms, optNoiseVec)
% 4. Non-linearity in the input stage (g3)

% Define input sinewave and sampling conditions
fs = OSR*2*fb;

N          = ceil(fs/fres);
nr_periods = ceil(fin/fres);
nr_steps   = ctSteps; % number of simulations steps per sample period

Vref_p = Vref;
Vref_n = -Vref;

% Thermo DAC elements (4-level)
if nargin < 20 
    elements = ones(1,1);
else
    elements = [(1-optDACMismatch) (1-optDACMismatch*0.1) (1+optDACMismatch)];
end

useDWA = false;
if nargin < 20
    randPermThermoElem = false;
else
    if strcmp(optDAC, "None")
        randPermThermoElem = false;
    elseif strcmp(optDAC, "Rand")
        randPermThermoElem = true;
    elseif strcmp(optDAC, "Rot")
        useDWA=true;
    else
        useDWA=false;
        randPermThermoElem = false;
    end
end

% DWA Pointer
elemPtr = 1;

% ****************************************
% DAC Waveforms
% ****************************************
% Defining DAC feedback signals with symmetrical rise and fall times
DAC_wave(1,(1:nr_steps)) = Vref_p.*ones(1,nr_steps);

% ****************************************
% Leaky Integrators
% ****************************************
pVec = [exp(-omCoeff(1)/(A0Vec(1))/fs) exp(-omCoeff(2)/(A0Vec(2))/fs) exp(-omCoeff(3)/(A0Vec(3))/fs) exp(-omCoeff(4)/(A0Vec(4))/fs)];  % loss factor

% ****************************************
% Allocate Arrays
% ****************************************
% Pre-allocate and initialize array variables => faster code
in = offset+amplitude*sin(2*pi*(fin/fs)*[1:N*nr_steps]/nr_steps)+amplitude_inter.*sin(2*pi*(finter/fs)*[1:N*nr_steps]/nr_steps);
y  = zeros(1,N); y(1) = Vref_n; wsum = y;
w1 = zeros(1,N*nr_steps); w2 = w1; w3 = w1; w4 = w1; w1_in = w1;

DAC_Test=zeros(1,N*nr_steps);
DAC = DAC_wave(1,:);

k1 = cCoeff(1);
k2 = cCoeff(2);
k3 = cCoeff(3);
k4 = cCoeff(4);

b1 = 1;

% Adjust coefficients to account for simulation step-size, 
% with limited DC gain of the intergrators
omega1 = omCoeff(1)/(fs*nr_steps);
omega2 = omCoeff(2)/(fs*nr_steps);
omega3 = omCoeff(3)/(fs*nr_steps);
omega4 = omCoeff(4)/(fs*nr_steps);

% if optLeakyInt == true
%     omega1 = alphaA0Vec(1)*omCoeff(1)/(fs*nr_steps);
%     omega2 = alphaA0Vec(2)*omCoeff(2)/(fs*nr_steps);
%     omega3 = alphaA0Vec(3)*omCoeff(3)/(fs*nr_steps);
%     omega4 = alphaA0Vec(4)*omCoeff(4)/(fs*nr_steps);
% end


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


ix = 1;

step_delay = eld;

gin3 = g3;
gdac3 = g3;

k0 = 0;
      
for a = 2:N
   
    % integrator pole displacement, leaky integrator
    if optLeakyInt == true
        w1(ix) = w1(ix)*pVec(1);
        w2(ix) = w2(ix)*pVec(2);
        w3(ix) = w3(ix)*pVec(3);
        w4(ix) = w4(ix)*pVec(4);
    end
    for b = 1:nr_steps
        ix = ix+1;
        
        w1_in(ix) = b1*(in(ix-1)-gin3.*in(ix-1).^3) - b1*(DAC(b)+gdac3.*DAC(b).^3);
        % NRZ DAC
        w4(ix) = w4(ix-1) + omega4*(   w3(ix-1) + noiseVec_rms(4)*randn()*sqrt(nr_steps));
        w3(ix) = w3(ix-1) + omega3*(   w2(ix-1) + noiseVec_rms(3)*randn()*sqrt(nr_steps));
        w2(ix) = w2(ix-1) + omega2*(   w1(ix-1) + noiseVec_rms(2)*randn()*sqrt(nr_steps));
        w1(ix) = w1(ix-1) + omega1*(w1_in(ix) + noiseVec_rms(1)*randn()*sqrt(nr_steps));
                
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
        DAC_Test(ix) = DAC(b);
    end
    wsum(a) = w1(ix)*k1+w2(ix)*k2+w3(ix)*k3+w4(ix)*k4+w1_in(ix)*k0;
    
    % 2-bit mid-rise DAC
    [y(a), thermoCode] = mbq(wsum(a), 2, Vref);

    if useDWA == false
        dacVal = Vref.*thermoDAC(thermoCode, elements, 2, randPermThermoElem);
        
    else
        [tmp, newElemPtr] = thermoDAC_DWA(thermoCode, elements, 2, elemPtr);
        dacVal = Vref.*tmp;
        elemPtr = newElemPtr;
    end
    
    DAC_prev = DAC;
    DAC_cur = ones(1,nr_steps).*dacVal;
    if step_delay > 0
        % ELD
        DAC = [DAC_prev(end-step_delay-1:end), DAC_cur(1:end-step_delay-1)];
    else
        DAC = DAC_cur;
    end
    
end
  %figure(3);plot(DAC_Test(1:1000));hold on;plot(DAC_Test(1:1000),'r*');title('A few samples of the feedback DAC signal with asymmetric rise and fall times');
end