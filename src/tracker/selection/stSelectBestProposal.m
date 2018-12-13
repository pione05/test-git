function [ tracks, frmProposal, selInd, selFlag ] = stSelectBestProposal( image, sedModel, mbModel, ...
    ebOpts, frmProposal, tracks, currFlows, noOfProp, prevRegion, mbThreshold, config, flags )
% Verify all the proposals and select the best one
%
% INPUTS
%   image - the current frame of the video
%   sedModel - loaded EdgeBox model
%   mbModel - loaded motion boundary model
%   ebOpts - EdgeBox parameters
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%   tracks - an instance of the Tracks class
%   currFlows - optical flows for the current frame
%   noOfProp - total number of proposals to be evaluated
%   prevRegion - bounding box region from the previous frame
%   mbThreshold - threshold for computing motion boundaries
%   config - an instance of the Config class
%   flags - structure with binary valued flags
%
% OUTPUTS
%   tracks - the updated tracks with the new values
%   frmProposal - updated structure containing data about the proposals of the
%                 current frame
%   selInd - proposal index selected as the best 
%   selFlag - integer flag indicating which selsction method was used
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    edgeboxRatioTh = config.edgeboxRatioThreshold;
    quantile = config.quantile;
    topN = config.topN;
    
    global VERBOSITY;

    if ~flags.USE_EDGE_SELECTION_FLAG && ~flags.USE_MOTION_SELECTION_FLAG
        if VERBOSITY > 0
            fprintf('Selection not using edge nor motion boundary\n');
        end
        [~, selInd] = max(frmProposal.detProp(:, 5));
        selFlag = 0;
    else
        [~, ind] = sort(frmProposal.detProp(:, 5),'descend');
        noOfCand = min(length(ind), topN);
        detFilterInd = ind(1:noOfCand);

        detScores = frmProposal.detProp(detFilterInd, 6);
        detRawScores = frmProposal.detProp(detFilterInd, 5);

        %% Step 2: choose significant detection score
        [maxDetScore, ~] = max(detScores);
        detScoresQuan = maxDetScore * (1 - quantile);
        candidateInd = detScores > detScoresQuan;

        selFlag = 0;
        if length(candidateInd) == 1    %detection score is significant better than other proposals
            if VERBOSITY > 0
                fprintf('One candidate has very high score\n');
            end
            selInd = candidateInd;
        else
            %% Do SED detection on the base image
            ebFlag = false;
            if flags.USE_EDGE_SELECTION_FLAG
                frmProposal = stComputeEdgeScores( image, sedModel, ebOpts, noOfProp, frmProposal );     
            
                ebScores = frmProposal.ebScores(detFilterInd);
                if VERBOSITY > 0
                    fprintf('Edge scores for all proposals\n');
                    disp(frmProposal.ebScores);
                end
                
                %find the best ebScore among all candidateInd
                ebScores(~candidateInd) = -1.0;    
                [maxEbScore, maxEbInd] = max(ebScores);

                %check validity of edgeboxes score
                if VERBOSITY > 1
                    fprintf('History of edge scores\n');
                    disp(tracks.ebScoreList);
                end
                [ebFlag, ebConf] = inlNormalizeScoreRobust(maxEbScore, tracks.getEbScoreWindow(), edgeboxRatioTh);
                if VERBOSITY > 0
                    fprintf('Max edge index: %d\n', maxEbInd);
                    fprintf('Max edge score: %0.04f\n', maxEbScore);
                    fprintf('Max edge confidence: %0.04f\n', ebConf);
                end
                
            end

           %% Do motion boundary detection on the base image
           mbFlag = false;
           mbMotionFlag = false;
           if ~isempty(currFlows) && flags.USE_MOTION_SELECTION_FLAG
               [frmProposal, mbMotionFlag] = stComputeMotionScores( tracks.prevIm, mbModel, ...
                   ebOpts, currFlows, prevRegion, mbThreshold, noOfProp, frmProposal );
                if VERBOSITY > 0
                    fprintf('mbMotionFlag: %d\n', mbMotionFlag);
                end
               if mbMotionFlag
                    if VERBOSITY > 0
                        fprintf('Motion scores for all proposals\n');
                        disp(frmProposal.mbScores);
                    end
                   mbScores = frmProposal.mbScores(detFilterInd);

                   %find the best mbScore among all candidateInd
                   mbScores(~candidateInd) = -1.0;    
                   [maxMbScore, maxMbInd] = max(mbScores);
                    if VERBOSITY > 1
                        fprintf('History of motion scores\n');
                        disp(tracks.mbScoreList);
                    end
                   %check validity of motion boundary score
                   [mbFlag, mbConf] = inlNormalizeScoreRobust(maxMbScore, tracks.getMbScoreWindow(), edgeboxRatioTh);
                    if VERBOSITY > 0
                        fprintf('Max motion index: %d\n', maxMbInd);
                        fprintf('Max motion score: %0.04f\n', maxMbScore);
                        fprintf('Max motion confidence: %0.04f\n', mbConf);
                    end
               end
           end
           
           if ~ebFlag && ~mbFlag
                if VERBOSITY > 0
                    fprintf('Selection based on detection score only\n');
                end
               [~, maxDetInd] = max(detRawScores);
               selInd = maxDetInd;
           elseif ~ebFlag && mbFlag
                if VERBOSITY > 0
                    fprintf('Selection based on motion\n');
                end
               selInd = maxMbInd;
               selFlag = 2;
           elseif ebFlag && ~mbFlag
                if VERBOSITY > 0
                    fprintf('Selection based on edge\n');
                end
               selInd = maxEbInd;
               selFlag = 1;
           else                             %both are valid 
                if VERBOSITY > 0
                    fprintf('Both edges and motions are accepted\n');
                end
               %compare confidence
               if ebConf > mbConf
                    if VERBOSITY > 0
                        fprintf('Selection: edge confidence > motion\n');
                    end
                   selInd = maxEbInd;
                   selFlag = 1;
               else
                    if VERBOSITY > 0
                        fprintf('Selection: motion confidence > edge\n');
                    end
                   selInd = maxMbInd;
                   selFlag = 2;
               end        
           end
           
           if flags.USE_EDGE_SELECTION_FLAG
               tracks = tracks.addEbScore(ebScores(selInd));
           end
           if mbMotionFlag && flags.USE_MOTION_SELECTION_FLAG
               tracks = tracks.addMbScore(mbScores(selInd));
           end
        end
        selInd = ind(selInd);
    end % if ~flags.USE_EDGE_SELECTION_FLAG && ~flags.USE_MOTION_SELECTION_FLAG
    if VERBOSITY > 0
        fprintf('Selected proposal index: %d\n', selInd);
    end
end

function [retFlag, confidence] = inlNormalizeScoreRobust(score, scoreList, edgeboxRatioTh)
    global VERBOSITY;
    
    scoreMean = 0;
    scoreStd = 0;
    if ~isempty(scoreList)
        scoreMean = mean(scoreList);
        scoreStd = std(scoreList);
    end

    eeps = 0.0000001;
    %select the high the better
    if score > scoreMean
        retFlag = true;
        confidence = (score - scoreMean) / (scoreStd + eeps);
    else    

        if abs(score - scoreMean) < edgeboxRatioTh * scoreStd
            retFlag = true;
        else
            retFlag = false;
        end    

        confidence = (score - scoreMean) / (scoreStd + eeps);
    end   

    if VERBOSITY > 1
        fprintf('History scores window\n');
        disp(scoreList);
        fprintf('Current score: %0.04f\n', score);
        fprintf('History score mean: %0.04f\n', scoreMean);
        fprintf('History score std: %0.04f\n', scoreStd);
        fprintf('Threshold (num of stds accepted): %0.04f\n', edgeboxRatioTh);
        fprintf('Current confidence: %0.04f\n', confidence);
        fprintf('accptFlag: %d\n', retFlag);
    end

end % inl function
