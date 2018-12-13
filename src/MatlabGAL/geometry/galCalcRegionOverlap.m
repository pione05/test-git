function overlap = galCalcRegionOverlap(region1, region2)
% Compute the overlap between input regions. The number of regions in region1
% and region2 can be different.
%
% It supports vectorized operation.
%
% USAGE
%   overlap = galCalcRegionOverlap(region1, region2)
%
% INPUTS
%   region1 - [N x 4/8] matrix, the format of each row is [x1 y1 x2 y2] or
%             [x1 y1 x2 y2 x3 y3 x4 y4]
%   region2 - [N x 4/8] matrix, the format of each row is [x1 y1 x2 y2] or
%             [x1 y1 x2 y2 x3 y3 x4 y4]
%
% OUTPUTS
%   overlap - scalar or vector
%
% EXAMPLE
%
% SEE ALSO
%   galCalcRectOverlap;
%
% KNOWN ISSUE
%   (1) The order of input regions will affect the results
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


[nRegion1, nDim1] = size(region1);
[nRegion2, nDim2] = size(region2);

rectFlag1 = false;

if nDim1 == 4
    region1 = galRectXY2RectWH(region1);
    rectFlag1 = true;
end

if nDim2 == 4
    region2 = galRectXY2RectWH(region2);
end

if nRegion1 == 1
    nOverlap = nRegion2;
    overlap = zeros(nOverlap, 3);

    for iOverlap = 1:nOverlap
        if rectFlag1
            overlap(iOverlap, :) = mexCalcRegionOverlap(region1, ...
                                                        region2(iOverlap, :));
        else
            overlap(iOverlap, :) = mexCalcRegionOverlap(region2(iOverlap, :), ...
                                                        region1);
        end

    end

elseif nRegion2 == 1
    nOverlap = nRegion1;
    overlap = zeros(nOverlap, 3);

    for iOverlap = 1:nOverlap
        if rectFlag1
            overlap(iOverlap, :) = mexCalcRegionOverlap(region1(iOverlap, :), ...
                                                        region2);
        else
            overlap(iOverlap, :) = mexCalcRegionOverlap(region2, ...
                                                        region1(iOverlap, :));
        end

    end
else
    nOverlap = min(nRegion1, nRegion2);
    overlap = zeros(nOverlap, 3);

    for iOverlap = 1:nOverlap
        if rectFlag1
            overlap(iOverlap, :) = mexCalcRegionOverlap(region1(iOverlap, :), ...
                                                        region2(iOverlap, :));
        else
            overlap(iOverlap, :) = mexCalcRegionOverlap(region2(iOverlap, :), ...
                                                        region1(iOverlap, :));
        end
    end
end

overlap = overlap(:, 1)';

end
