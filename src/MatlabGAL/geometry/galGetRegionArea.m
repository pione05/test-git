function area = galGetRegionArea(region)
% Get the area of input region.
%
% USAGE
%   area = galGetRegionArea(region)
%
% INPUTS
%   region - 8/4-dim vector, the format is [x1 y1 x2 y2] or
%            [x1 y1 x2 y2 x3 y3 x4 y4]
%
% OUTPUTS
%   area - scalar, the area of input region
%
% EXAMPLE
%
% SEE ALSO
%   galGetRectArea
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


canvasWidth = round(max(region(1:2:end)) + 10);
canvasHeight = round(max(region(2:2:end)) + 10);

mask = galGenPolygonMask(region, canvasWidth, canvasHeight);
area = galGetMaskArea(mask);

end
