function flag = galPtsInMask(pts, mask)
% Check whether the input points are inside the mask or not.
%
% It supports vectorized operation.
%
% USAGE
%   flag = galPtsInMask(pts, mask)
%
% INPUTS
%   pts  - [N x 2] matrix, the format of each is [x y]
%   mask - matrix, the value larger than 0 indicate mask
%
% OUTPUTS
%   flag - vector, 1 indiates that the corresponding point is inside the mask
%
% EXAMPLE
%
% See also
%   galPtsInRegion, galPtsInRect
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


flag = mask(sub2ind(size(mask), pts(:,2), pts(:, 1)));

end
