function rectxy = galRegion2RectWithSameArea(region, tempWidth, tempHeight)
% Convert input region (8 coordinates or 4 coordinates) to regular
% rectangle and keep the same area
%
% % USAGE
%   rectxy = galRegion2RectWithSameArea(region, tempWidth, tempHeight)
%
% INPUTS
%   region - region represented by 8 coordinates or 4 coordinates
%   tempWidth - the width of rectangle template (i.e., minimum size)
%   tempHeight - the height of rectangle template (i.e., minimum size)
%
% OUTPUTS
%   rectxy - rectangle represented by [x1 y1 x2 y2]
%
% EXAMPLE
%
% SEE ALSO
%   galRegion2RectBFS
%
% TODO
%   (1) Support vectorized operation
%   (2) Set default value for tempWidth and tempHeight
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if size(region, 2) == 4
    rectxy = [region(:, 1) region(:, 2) region(:, 3) region(:, 4)];

elseif size(region, 2) == 8
    %get the center of region

    x1 = min(region(1:2:end));
    x2 = max(region(1:2:end));
    y1 = min(region(2:2:end));
    y2 = max(region(2:2:end));

    regionCenterX = 0.5 * (x1 + x2);
    regionCenterY = 0.5 * (y1 + y2);

    regionArea = galGetRegionArea(region);

    tempArea = tempWidth * tempHeight;

    if regionArea < tempArea
        rectWidth = tempWidth;
        rectHeight = tempHeight;
    else
        ratio = sqrt(regionArea / tempArea);

        rectWidth = tempWidth * ratio;
        rectHeight = tempHeight * ratio;
    end

    rectxy = galGenRectFromCenterSize([regionCenterX regionCenterY], ...
                                      [rectWidth rectHeight]);

else
    error('Invalid region input!');
end

end 
