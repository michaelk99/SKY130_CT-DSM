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

%% Test Plot ADC TF
clear all; close all; clc;
addpath('../../../../python-deltasigma/delsig/')
addpath('../../utility/')
addpath('../')

%% M step mid rise quantizer [Schreier]
n = 2;
nlev = 2.^n;
M = nlev-1;
vref = 0.36;
Delta = vref/2;
VinMax = (M+1)*Delta/2;
outMax = M/2*Delta;
in = -1.5*vref:vref/100:1.5*vref;
index = uencode(in, n, vref, "unsigned");
% q_out = (single(index)-max(single(index))./2);
q_out = (single(index)-M./2);
q_out = q_out./M*2*vref;
% DeltaNorm = 2/M;
% inNorm = in/vref + 1; % normalize input and shift to pos values
% q = floor(inNorm/DeltaNorm).*DeltaNorm - 1; % quantize to integer mult of deltaNorm, shift back
% q_out = sign(in).*min(abs(q),1);
% index = round((q_out+1)/DeltaNorm);
figure;
% plot(in, q_out);
hold on;
% plot(in,index);
plot(in, q_out);
grid on;



%% Test mbq()
clear all; close all; clc;
vref = 0.75;
% nlev = 2.^2;
nlev = 3;
% in = -vref:vref/100:vref;
fin = 18;
fs = 2.^16;
fres = 1/8;
N = floor(fs/fres);
in = vref.*sin(2*pi*(fin/fs)*[1:N]);
[out, thermo] = mbq(in, nlev, vref);
out4 = ds_quantize((nlev-1)*in/vref,nlev);
thermo4 = (out4+(nlev-1))/2;
 
figure;
plot(in,out)
hold on;
plot(in,out4)
title('mbq() Test - Sine Input - Vector')
grid on;
figure;
plot(in, thermo)
hold on;
plot(in, thermo4)
title('mbq() Test - Sine Input - Thermocode - Vector')
grid on;

out2 = zeros(1,length(in));
out3 = out2;
thermo2 = out2;
for i=1:length(in)
    [out2(i), thermo2(i)] = mbq(in(i), nlev, vref);
    out3(i) = ds_quantize((nlev-1)*in(i)/vref, nlev);
end

figure;
plot(in,out2)
hold on;
plot(in,out3)
grid on;
title('mbq() Test - Sine Input - Elementwise')
figure;
plot(in, thermo2)
grid on;
title('mbq() Test - Sine Input - Elementwise')
%% Test ADC - DAC combo
elements = ones(1,nlev-1);
out_dac = zeros(1,length(thermo));
ptr=1;
for i=1:length(thermo)
    [tmp, ptrNew] = thermoDAC_DWA(thermo(i), elements, nlev, ptr);
    out_dac(i) = vref.*tmp;
    ptr = ptrNew;
end
figure;
plot(in, out_dac);
hold on;
% plot(in, out);
% plot(in, in-out_dac)
title('ADC-DAC Cascade TF')
grid on;
