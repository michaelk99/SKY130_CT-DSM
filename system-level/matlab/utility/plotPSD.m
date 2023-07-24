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

function plotPSD(V, NBW, N, fres, fb, optLog, optdB)
    if nargin < 7
        optdB = true;
    end
    if optdB == true
        psd = 20*log10(abs(V));
    else
        psd = abs(V);
    end
    figure;
    if optLog == true
        semilogx((1:round(N/2))*fres,psd(1:round(N/2)),'LineWidth',1);
    else
        plot((1:round(N/2))*fres,psd(1:round(N/2)),'LineWidth',1);
    end
    xline(fb, 'k--');
    text(1e3, -225, sprintf('NBW = %.2d', NBW),'Fontsize', 14) 
    set(gca,'FontSize',14)
    grid on; xlabel('Frequency [Hz]'); ylabel('PSD [dBFS/NBW]')
    title('Output Spectrum $\Sigma\Delta$ Modulator', 'Interpreter', 'Latex');
end
