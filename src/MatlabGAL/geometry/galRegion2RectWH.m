function rectwh = galRegion2RectWH(region)
% Convert input region (8 coordinates or 4 coordinates) to regular rectangle.
%
% It supports vectorized operation.
%
% USAGE
%   rectxy = galRegion2RectXY(region)
%
% INPUTS
%   region - [N x 8/4] matrix, the format of each row is [x1 y1 x2 y2] or
%            [x1 y1 x2 y2 x3 y3 x4 y4]
%
% OUTPUTS
%   rectxy - [N x 4] matrix, the format of each row is [x1 y1 w h]
%
% EXAMPLE
%
% SEE ALSO
%   galRegion2RectWH
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


rectxy = galRegion2RectXY(region);
rectwh = galRectXY2RectWH(rectxy);

end
