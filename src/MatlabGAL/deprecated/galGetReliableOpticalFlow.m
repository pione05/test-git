function [ newPrevPt, newCurrPt ] = galGetReliableOpticalFlow( prevPt, currPt, backFlows, imageSize, errorThreshold )
% Filter the set of currPoints by keeping only those whose backward
% projection with the backward optical flow agree with the given previous
% points
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('errorThreshold', 5);

global VERBOSITY;

minBounds = ones(2, 1);
maxBounds = imageSize(1:2);
[currPtsInside, currPtsInsideMask] = galGetPtsInsideBoundaries( currPt, minBounds, maxBounds );
newPrevPt = prevPt(currPtsInsideMask, :);
if VERBOSITY > 0
    numFlowDiff = size(prevPt, 1) - size(newPrevPt, 1);
    fprintf('Removed %d flow vectors outside boundaries out of %d.\n', numFlowDiff, size(prevPt, 1));
end

interFlows = galCalcInterpolatedFlow( currPtsInside, backFlows );
backWarpPt = currPtsInside + interFlows;
pixDist = sqrt((backWarpPt(:, 1) - newPrevPt(:, 1)).^2 + (backWarpPt(:, 2) - newPrevPt(:, 2)).^2);
keepInd = find(pixDist < errorThreshold);
newPrevPt = newPrevPt(keepInd, :);
newCurrPt = currPtsInside(keepInd, :);

if VERBOSITY > 1
    fprintf('galGetReliableOpticalFlow\n');
    fprintf('flow field size\n');
    disp(size(backFlows));
    fprintf('prevPt\n');
    disp(prevPt)
    fprintf('currPt\n');
    disp(currPt)
    fprintf('interFlows\n');
    disp(interFlows)
    fprintf('backWarpPt\n');
    disp(backWarpPt)
    fprintf('pixDist\n');
    disp(pixDist)
    fprintf('newPrevPt\n');
    disp(newPrevPt)
    fprintf('newCurrPt\n');
    disp(newCurrPt)
    fprintf('origSize: %d, filteredSize: %d\n', size(prevPt, 1), size(newPrevPt, 1));
end

if VERBOSITY > 0
    numFlowDiff = size(currPtsInside, 1) - size(newCurrPt, 1);
    fprintf('Removed %d unreliable flow vectors out of %d. Max error: %0.01f pixels\n', numFlowDiff, size(currPtsInside, 1), max(pixDist));
    totalNumFlowDiff = size(currPt, 1) - size(newCurrPt, 1);
    fprintf('In total, %d flow vectors were removed.\n', totalNumFlowDiff);
end
end
