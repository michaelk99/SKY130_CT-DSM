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

% Realizes a mid-rise multi-bit quantizer
% "nr_levels" = number of levels between -vref and +vref
% "index" = [0 .. nr_levels-1] is the number of DAC elements with the value of +1
% All other DAC elements should have a value of -1

function [q_out, index] = mbq(in, nr_levels, vref)
    if nr_levels == 2
        index = double((in>=0));
        q_out = 2*index-1;
    elseif nr_levels == 3
    % TBD
    elseif nr_levels > 3
        M = nr_levels-1;
        index = double(uencode(in, log2(nr_levels), vref, "unsigned"));
        q_out = (index-M./2);
        q_out = q_out./M*2;
    end
end
