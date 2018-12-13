function testGetRegionArea
% Test galGetRegionArea function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));


region = [324.2900 220.1000 346.5100 162.2200 ...
          371.7100 171.9000 349.4900 229.7800];

area = galGetRegionArea(region)

rect = [100 100 200 200];
area = galGetRegionArea(galRectXY2Region(rect))

% canvasWidth = round(max(region(1:2:end)) + 10);
% canvasHeight = round(max(region(2:2:end)) + 10);
% 
% %mask = galGenPolygonMask(region, canvasWidth, canvasHeight);
% 
% xCoords = double([region(1:2:end) region(1)]);
% yCoords = double([region(2:2:end) region(2)]);
% 
% maskIm = poly2mask(xCoords, yCoords, double(canvasHeight), double(canvasWidth));
% 
% figure;
% imshow(maskIm)

end
