function regionCenter = galGetRegionCenter(region)
% Get the center point of input region.
%
% USAGE
%   regionCenter = galGetRegionCenter(region)
%
% INPUTS
%   region - [N x 8] matrix, the format of each row is [x1 y1 x2 y2 x3 y3 x4 y4]
%
% OUTPUTS
%   regionCenter - [N x 2] matrix, the format of each row is [x y]
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


rectxy = galRegion2RectXY(region);

regionCenter = galGetRectCenter(rectxy);

end
