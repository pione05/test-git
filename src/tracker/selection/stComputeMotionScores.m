function [frmProposal, mbMotionFlag] = stComputeMotionScores( image, mbModel, ...
    ebOpts, currFlows, prevRegion, mbThreshold, noOfProp, frmProposal )
% Compute motion boundary scores for the proposals
%
% INPUTS
%   image - the current frame of the video
%   mbModel - loaded motion boundary model
%   ebOpts - EdgeBox parameters
%   currFlows - optical flows for the current frame
%   prevRegion - region bouding box from previous frame
%   mbThreshold - threshold for computing motion boundaries
%   noOfProp - total number of proposals to be evaluated
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%
% OUTPUTS
%   frmProposal - updated structure containing data about the proposals of the
%                 current frame
%   mbMotionFlag - boolean flag indicating if the motion was above the
%                  threshold of not
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    %check motion status within region
    mbMotionFlag = stCheckMotionStatus(currFlows, prevRegion, mbThreshold);

    if mbMotionFlag
        nThreads = 4;
        mbInput = cat(3, single(image)/255, currFlows/10);
        [mbProb, mbOrien] = mbEdgesDetect(mbInput, mbModel);

        detMbScores = stCalcEdgeBoxScoreFromConfOrien(mbProb, mbOrien,...
            frmProposal, noOfProp, ebOpts, nThreads);
        frmProposal.mbScores(1:noOfProp, :) = detMbScores;   
    end % if mbMotionFlag   
end

