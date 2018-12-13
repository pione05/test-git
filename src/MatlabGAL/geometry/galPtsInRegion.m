function flag = galPtsInRegion(pts, region, width, height)
% Check whether the input points inside the region or not.
%
% USAGE
%
% INPUTS
%   pts  - [N x 2] matrix, the format of each line is [x y]
%   region - 8-dim vector, the format is [x1 y1 x2 y2 x3 y3 x4 y4]
%   width - scalar, width of canvas (optional)
%   height - scalar, height of canvas (optional)
%
% OUTPUTS
%   flag - [N x 1] vector, 1 indiates the corresponding point is inside
%          the region
%
% EXAMPLE
%
% See also
%   galPtsInMask, galPtsInRect
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%prepare the canvas
ptMax = max(pts);
regionX = max(region(1:2:end));
regionY = max(region(2:2:end));

canvasWidth = ceil(max(ptMax(1), regionX)) + 10;
canvasHeight = ceil(max(ptMax(2), regionY)) + 10;

galSetDefaultVal('width', canvasWidth);
galSetDefaultVal('height',  canvasHeight);

mask = galGenPolygonMask(region, width, height);

flag = galPtsInMask(pts, mask);

end
