function rect = galRegion2RectWithSameAspect(region, tempWidth, tempHeight)
% Convert input region (8 coordinates or 4 coordinates) to regular rectangle
% with the same aspect ratio of the template
%
% % USAGE
%   rect = galRegion2RectWithSameAspect(region, tempWidth, tempHeight)
%
% INPUTS
%   region - 8/4-dim vector, input region
%   tempWidth - template width constraint
%   tempHeight - template height constraint
%
% OUTPUTS
%   rectxy - vector, the format of rectangle is [x1 y1 x2 y2]
%
% EXAMPLE
%
% SEE ALSO
%   galRegion2RectBFS
%
% TODO
%   (1) Support vectorized operation
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if numel(region) > 4
    x1 = min(region(1:2:end));
    x2 = max(region(1:2:end));
    y1 = min(region(2:2:end));
    y2 = max(region(2:2:end));

    regionWidth = x2 - x1;
    regionHeight = y2 - y1;

    regionCenterX = 0.5 * (x1 + x2);
    regionCenterY = 0.5 * (y1 + y2);

    %calculate width-height ratio
    regionRatio = single(regionWidth) / single(regionHeight);
    tempRatio = single(tempWidth) / single(tempHeight);

    if regionRatio > tempRatio  %keep width
        scale = single(regionWidth) / single(tempWidth);

        rectWidth = regionWidth;
        rectHeight = tempHeight * scale;

    else                        %keep height
        scale = single(regionHeight) / single(tempHeight);

        rectWidth = tempWidth * scale;
        rectHeight = regionHeight ;
    end

    %set to tempSize if the bounding box become too small
    if rectWidth * rectHeight < tempWidth * tempHeight
        rectWidth = tempWidth;
        rectHeight = tempHeight;
    end

    rect = galGenRectFromCenterSize([regionCenterX regionCenterY], [rectWidth rectHeight]);

else
    rect = [region(1) region(2) region(3) region(4)];
end

end
