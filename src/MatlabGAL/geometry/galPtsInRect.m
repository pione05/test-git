function flag = galPtsInRect(pts, rect)
% Check whether the input points are inside rectangle or not.
%
% It supports vectorized operation.
%
% USAGE
%   flag = galPtsInRect(pts, rect)
%
% INPUTS
%   pts  - [N x 2] matrix, the format of each is [x y]
%   rect - vector, the format is [x1 y1 x2 y2]
%
% OUTPUTS
%   flag - vector, 1 indiates that the corresponding point is inside
%          the rectangle
%
% EXAMPLE
%
% See also
%   galPtsInRegion, galPtsInMask
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


flag = pts(:,1) >= rect(1) & pts(:,1) <= rect(3) & ...
       pts(:,2) >= rect(2) & pts(:,2) <= rect(4);

end
