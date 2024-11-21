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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) R. Schreier
% function v = ds_quantize(y,n)
% %v = ds_quantize(y,n)
% %Quantize y to 
% % an odd integer in [-n+1, n-1], if n is even, or
% % an even integer in [-n, n], if n is odd.
% %
% %This definition gives the same step height for both mid-rise
% %and mid-tread quantizers.
% 
% if rem(n,2)==0	% mid-rise quantizer
%     v = 2*floor(0.5*y)+1;
% else 		% mid-tread quantizer
%     v = 2*floor(0.5*(y+1));
% end
% 
% % Limit the output
% for qi=1:length(n)	% Loop for multiple quantizers
%     L = n(qi)-1;
%     i = v(qi,:)>L; 
%     if any(i)
% 	v(qi,i) = L;
%     end
%     i = v(qi,:)<-L;
%     if any(i)
% 	v(qi,i) = -L;
%     end
% end

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
        q_out = ds_quantize((nr_levels-1)*in/vref,nr_levels);
        index = (q_out+(nr_levels-1))/2;
    elseif nr_levels > 3
        M = nr_levels-1;
        index = double(uencode(in, log2(nr_levels), vref, "unsigned"));
        q_out = (index-M./2);
    end
end
