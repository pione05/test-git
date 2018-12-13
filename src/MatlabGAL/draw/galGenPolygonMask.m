function maskIm = galGenPolygonMask(region, imWidth, imHeight)
% Generate polygon mask image with imWidth and imHeight
%
% USAGE
%
% INPUTS
%   region - vector, the format is [x1 y1 x2 y2 x3 y3 x4 y4]
%   imWidth - scalar, the width of output mask image
%   imHeight - scalar, the height of output mask image
%
% OUTPUTS
%   maskIm - [imHeight, imWidth] matrix, bool type image
%
% EXAMPLE
%
%
% ATTENTION
%   The generated mask shifts 1 pixel from input region and supports
%   subpixel input.
%
% SEE ALSO
%
% REFERENCE
% [1] http://www.mathworks.com/help/images/ref/regionfill.html
% [2] http://www.mathworks.com/help/images/ref/poly2mask.html
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if length(region) < 4
    error('Input region is invalid!');
end

if length(region) == 4
    region = galRectXY2Region(region);
end

xCoords = double([region(1:2:end) region(1)]);
yCoords = double([region(2:2:end) region(2)]);

maskIm = poly2mask(xCoords, yCoords, imHeight, imWidth);

end
