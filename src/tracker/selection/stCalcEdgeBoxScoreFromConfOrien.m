function ebScores = stCalcEdgeBoxScoreFromConfOrien(confMap, orienMap, frmProposal,...
    noOfProp, ebOpts, nThreads)
% Compute scores for all frame proposals from the
% edge confidences and orientations.
%
% INPUTS
%   confMap - map of confidences from EdgeBox
%   orienMap - map of orientations from EdgeBox
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%   noOfProp - total number of proposals to be evaluated
%   ebOpts - EdgeBox parameters
%   nThreads - number of parallel threads that can be used to compute the
%              scores
%
% OUTPUTS
%   ebScores - array of scores, one for each proposal
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


nmsConfMap = edgesNmsMexWrapper(confMap, orienMap, 2, 0, 1, nThreads);  

ebScores = zeros(noOfProp, 1);
for kProp = 1:noOfProp
    rotEdgeProb = imrotate(nmsConfMap, -frmProposal.baseAngle(kProp), 'nearest', 'loose');
    rotEdgeOrien = imrotate(orienMap, -frmProposal.baseAngle(kProp), 'nearest', 'loose');
    
    rect = single(galRectXY2RectWH(frmProposal.detProp(kProp, 1:4)));

    
    retval = calcEdgeBoxScoreMex(rotEdgeProb, rotEdgeOrien, rect, ebOpts.alpha, ebOpts.beta, ebOpts.eta, ...
                       ebOpts.minScore,ebOpts.maxBoxes, ebOpts.edgeMinMag, ...
                       ebOpts.edgeMergeThr, ebOpts.clusterMinMag, ebOpts.maxAspectRatio, ...
                       ebOpts.minBoxArea, ebOpts.gamma, ebOpts.kappa);
    ebScores(kProp) = retval(:, 5);
end               
end

