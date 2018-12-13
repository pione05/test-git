function [newPts, newPtsMask] = galGetPtsInsideBoundaries( pts, minBounds, maxBounds )
% Filter a set of points by removing those that are outside the boundaries.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


validInd = ones(size(pts, 1), 1);

for i=1:size(minBounds, 1)
    insideInd = pts(:, i) >= minBounds(i);
    validInd = validInd .* insideInd;
    insideInd = pts(:, i) <= maxBounds(i);
    validInd = validInd .* insideInd;
end

newPtsMask = logical(validInd);
newPts = pts(newPtsMask, :);
