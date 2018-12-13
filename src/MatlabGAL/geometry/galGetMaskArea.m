function area = galGetMaskArea(mask)
% Get the area of mask.
%
% USAGE
%   area = galGetMaskArea(mask)
% INPUTS
%   mask - matrix, the value of pixel is set to 0 for background while to larger
%          than 0 for mask region
%
% OUTPUTS
%   area - scalar, area of mask
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


area = sum(sum(mask>0));

end
