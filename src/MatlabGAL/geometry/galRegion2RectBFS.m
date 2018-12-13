function [rectxy, varargout] = galRegion2RectBFS(region, im, tempWidth, ...
                                                 tempHeight)
% Convert input region (8 coordinates or 4 coordinates) to regular
% rectangle with brute force search in order to find the best overlap
% rectangle with input region.
%
% It supports two kinds of usages
%   (1) input region and search the best overlap rectangle without template constraints
%   (2) input region and search the best overlap rectangle with template
%   constrains (keep the same aspect ratio and can not be smaller than template)
%
% USAGE
%   [rectxy, ovrlp] = galRegion2RectBFS(region, im)
%   [rectxy, ovrlp] = galRegion2RectBFS(region, im, tempWidth, tempHeight)
%
% INPUTS
%   region - 8/4-dim vector, input region
%   im - matrix, if input region with 4 coordinates, im is optional
%   tempWidth - template width constraint (optional for usage 1)
%   tempHeight - template height constraint (optional for usage 1)
%
% OUTPUTS
%   rectxy - vector, the format of rectangle is [x1 y1 x2 y2]
%   ovrlp - scalar, the best overlap between input region and return rectangle
%           (optional)
%
% EXAMPLE
%
% SEE ALSO
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


% Set default value
galSetDefaultVal('im', []);

% Internal setting
bfsStep = 0.5;
bfsRange = 10;

bfsRatioStep = 0.001;
bfsRatioRange = 0.1;

if size(region, 2) == 4
    rectxy = [region(:, 1) region(:, 2) region(:, 3) region(:, 4)];
    retOvrlp = 1.0;
elseif size(region, 2) == 8
    [imHeight, imWidth, ~] = size(im);

    if nargin == 2                      %without template width/height input
        edgePts = zeros(4, 2);
        vertexPts = zeros(4, 2);
        for i = 0:3
            vertexPts(i+1, :) = [region(i*2+1) region(i*2+2)];
        end

        for i = 1:4
            j = i+1;
            if j>4
                j=1;
            end
            edgePts(i, :) = (vertexPts(i,:) + vertexPts(j, :)) ./ 2.0;
        end

        initWidth = norm(edgePts(1, :) - edgePts(3, :));
        initHeight = norm(edgePts(2, :) - edgePts(4, :));

        [rectWidthFirst, ovrlpWidthFirst] = inlBruteForceSearch(region, ...
                    initWidth, initHeight, imWidth, imHeight, bfsStep, bfsRange);
        [rectHeightFirst, ovrlpHeightFirst] = inlBruteForceSearch(region, ...
                    initHeight, initWidth, imWidth, imHeight, bfsStep, bfsRange);

        %TODO: potential risk for invalid rectangle
        if ~isempty(rectWidthFirst) && ~isempty(rectHeightFirst)
            if ovrlpWidthFirst > ovrlpHeightFirst
                rectxy = rectWidthFirst;
                retOvrlp = ovrlpWidthFirst;
            else
                rectxy = rectHeightFirst;
                retOvrlp = ovrlpHeightFirst;
            end
        elseif isempty(rectWidthFirst) && isempty(rectHeightFirst)
            error('invalid for generating rects')
        elseif isempty(rectWidthFirst)
            rectxy = rectHeightFirst;
            retOvrlp = ovrlpHeightFirst;
        elseif isempty(rectHeightFirst)
            rectxy = rectWidthFirst;
            retOvrlp = ovrlpWidthFirst;
        else
            error('invalid rectangle style!');
        end


    elseif nargin == 4                 %with template width/height input
        regionCenter = galGetRegionCenter(region);
        regionArea = galGetRegionArea(region);

        tempArea = tempWidth * tempHeight;

        if regionArea < tempArea
            rectWidth = tempWidth;
            rectHeight = tempHeight;

            rectxy = galGenRectFromCenterSize(regionCenter, [rectWidth rectHeight]);
            retOvrlp = galCalcRegionOverlap(rectxy, region);
        else
            %do scale brute force search
            baseRatio = sqrt(regionArea / tempArea);

            bfsRatio = baseRatio-bfsRatioRange:bfsRatioStep:baseRatio+bfsRatioRange;
            testRect = zeros(numel(bfsRatio), 4);

%             galShowIm(im)
            for i = 1:numel(bfsRatio)
                bfsWidth = tempWidth * bfsRatio(i);
                bfsHeight = tempHeight * bfsRatio(i);

                if bfsWidth * bfsHeight < tempWidth * tempHeight
                    continue;
                end

                testRect(i, :) = galGenRectFromCenterSize(regionCenter, [bfsWidth bfsHeight]);
            end
            ovrlp = galCalcRegionOverlap(testRect, region);
            [retOvrlp, ind] = max(ovrlp);
            rectxy = testRect(ind, :);

        end

    else
        error('Invalid input!');

    end
else
    error('Invalid region input!');
end

if nargout == 2
    varargout{1} = retOvrlp;
end

end %function


function [rect, ovrlp] = inlBruteForceSearch(initRegion, initWidth, initHeight, imWidth, imHeight, bfsStep, bfsRange)

    widthStart = max(1, initWidth-bfsRange);
    widthEnd = min(imWidth -1, initWidth+bfsRange);

    heightStart = max(1, initHeight-bfsRange);
    heightEnd = min(imHeight -1, initHeight+bfsRange);
    [bfsWidth, bfsHeight] = meshgrid(widthStart:bfsStep:widthEnd, heightStart:bfsStep:heightEnd);

    regionCenter = galGetRegionCenter(initRegion);

    testRect = zeros(numel(bfsWidth), 4);
    tic
    for i = 1:numel(bfsWidth)
        testRect(i, :) = galGenRectFromCenterSize(regionCenter, [bfsWidth(i) bfsHeight(i)]);
    end
    rectOvrlp = galCalcRegionOverlap(testRect, initRegion);
    [ovrlp, ind] = max(rectOvrlp);
    rect = testRect(ind, :);

end %inlBruteForceSearch
