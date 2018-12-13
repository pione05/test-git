function frmProposal = stAddFrmProposalData( frmProposal, initIndex, endIndex,...
    rect, region, baseAngle, angleConf, detIm )
% Include the proposal data into the frmProposal structure.
%
% INPUTS
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%   initIndex - starting position of the frmProposal to insert the data
%   endIndex - ending position of the frmProposal to insert the data
%   rect - rectangle presentation (2 points) of the proposal
%   region - region representation (4 points) of the proposal
%   baseAngle - angles of each proposal
%   angleConf - confidence scores for each angle
%   detIm - base image used to compute the proposals
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


frmProposal.detProp(initIndex:endIndex, :) = rect;
frmProposal.regionProp(initIndex:endIndex, :) = region;
frmProposal.baseAngle(initIndex:endIndex, :) = baseAngle;
frmProposal.angleConf(initIndex:endIndex, :) = angleConf;
frmProposal.detIm(initIndex:endIndex) = detIm;

end

