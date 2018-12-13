function frmProposal = stComputeEdgeScores( image, sedModel, ebOpts, noOfProp, frmProposal )
% Compute edgebox scores for the proposals
%
% INPUTS
%   image - the current frame of the video
%   sedModel - loaded EdgeBox model
%   ebOpts - EdgeBox parameters
%   noOfProp - total number of proposals to be evaluated
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%
% OUTPUTS
%   frmProposal - updated structure containing data about the proposals of the
%                 current frame
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    [edgeProb, edgeOrien] = edgesDetect(image, sedModel); 

    detEbScores = stCalcEdgeBoxScoreFromConfOrien(edgeProb, edgeOrien,...
        frmProposal, noOfProp, ebOpts, sedModel.opts.nThreads);
    
    frmProposal.ebScores(1:noOfProp, :) = detEbScores;  

end

