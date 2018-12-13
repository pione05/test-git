function [f1, mo, ovrlps] = galEvalTracksRegion(gts, bbs, THR)
% Compute f1 and mo measures for the given observations.
%
% USAGE
%   [f1, mo, ovrlps] = galEvalTracksRegion(gts, bbs, THR)
%
% INPUTS
%   gts: [N x 8/4] matrix, ground truth boxes
%   bbs: [N x 8/4] matrix, tracking bounding boxes
%   THR: scalar, overlap threshold (optional, the default is 0.5)
%
% OUTPUTS
%   f1: scalar, f1 value
%   mo: scalar, mean overlap
%   ovrlps: [N x 1] vector, overlap between ground boxes and
%           tracking bounding boxes
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if nargin < 3
    THR = 0.5;
end

totalNumberOfGTs = 0;
totalNumberOfBBs = 0;
sumOfCorrectDet = 0;
sumOfCorrectDetForRecall = 0;

ovrlps = galCalcRegionOverlap(gts, bbs);

nFrms = length(ovrlps);

for iFrm = 1:nFrms
    totalNumberOfGTs = totalNumberOfGTs + 1;
    totalNumberOfBBs = totalNumberOfBBs + 1;

    if ovrlps(iFrm) > THR
        sumOfCorrectDetForRecall = sumOfCorrectDetForRecall + 1;
        sumOfCorrectDet = sumOfCorrectDet + 1;
    end
end

p = sumOfCorrectDet / totalNumberOfBBs;
r = sumOfCorrectDetForRecall / totalNumberOfGTs;
f1 = 2 * p * r / (p+r);
mo = mean(ovrlps);

end
