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

function plotInternalSignals(fs, fin, nr_steps, signalVec, labelVec, optZoom)
    nop = size(signalVec);
    nop = nop(1);
    figure;
    for i=1:nop
        subplot(nop,1,i); 
        plot(signalVec(i,:),'b','LineWidth',1.5);
        xlabel('Samples'); ylabel(labelVec(i));  grid on;
        set(gca,'FontSize',14)
        if optZoom == true
            xlim([0, nr_steps*fs/fin]);
        end
    end
end