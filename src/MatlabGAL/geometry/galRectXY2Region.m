function region = galRectXY2Region(rectxy)
% Convert input rectangle to region.
%
% It supports vectorized operation.
%
% USAGE
%   region = galRectXY2Region(rectxy)
%
% INPUTS
%   rectxy - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   region - [N x 8] matrix, the format of each row is
%            [x1 y1 x2 y2 x3 y3 x4 y4]
%
% EXAMPLE
%
% See also
%   galRegion2RectXY
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


x1 = rectxy(:, 1); y1 = rectxy(:, 2); x2 = rectxy(:, 3); y2 = rectxy(:, 4);
region = [x1 y1 x2 y1 x2 y2 x1 y2];

end
