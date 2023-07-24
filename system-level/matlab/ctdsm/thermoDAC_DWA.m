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

% Realizes a thermometer DAC implementing "nr_levels" levels and using
% a rotational element selection logic (DWA)
% "elements" is a vector of NORMALIZED unit DAC elements 
% "index" = [0 .. nr_levels-1] is the thermometer code provided by the quantizer
% "ptr" points to the last unit-element used by the last call

function [DAC, ptr] = thermoDAC_DWA(index, elements, nr_levels, ptr)    
    nr_elements = nr_levels - 1;      % number of DAC elements
    DACvect = -ones(1,nr_elements);   % Reset all elements to -1
    idx = mod(ptr+index-1, nr_elements);
    if index > 0
        if ptr <= idx
            DACvect(ptr:idx) = 1;             % Set "index" DAC elements to +1
        else 
            DACvect(ptr:end) = 1;
            DACvect(1:idx) = 1;
        end
    end
    DAC = (elements*DACvect')/nr_elements; % Build the DAC output from the given unit elements
    ptr = idx+1;
end