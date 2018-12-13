function [ofhtRegion, ofhtDet, ofhtRotIm, ofhtBaseAngle, ofhtConf, noOfOFHTProp, motionFlag] = ...
                stOFHTProposalRotDetSmoothForMotion(region, flows, isNewTrack, model, ...
                maxNoOfProp, prevBaseAngle, prevMeanDeltaAngle, prevMeanAngleConf, im, config)           
% Apply optical flow hough transform for new tracking region proposal based on 
% tracking region and masks from previous frame. All proposals will be convert 
% detection rectangle and calculate detection scores.
%
% USAGE
%   [selbb, selInd] = stOFHTSelection(detbb, lastbb, vidName, frmNo, im, gtRegion)
%
% INPUTS
%   region - 8-dim vector, region from previous frame, which is the base
%            for ofht proposal generation 
%   vidName - string, video name for optical flow loading
%   isNewTrack - boolean, indicate if it is the first tracked frame of the
%                video
%   model - svm model, to calculate detection score on new proposals
%   maxNoOfProp - int, default value is 5 (optional)
%   im - matrix, to check region validity
%
% OUTPUTS
%   selbb  - selected bounding box from detbbcd -
%   selInd - selected bounding box index from detbb
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


global VERBOSITY;

%% configuration
ANGLE_DIFF_MAX_TH = config.maxAngleDiffThreshold;
ANGLE_DIFF_MIN_TH = config.minAngleDiffThreshold;
CONFIDENCE_RATIO_THRESHOLD = config.confidenceThreshold;

MOTION_MAG_TH = config.motionMagnitudeThreshold;

%% parameters setting
% Optical flow 

galSetDefaultVal('maxNoOfProp', 5);
galSetDefaultVal('gtRegion', []);

[imHeight, imWidth, ~] = size(im);

%% Optical Flow Hough Transform Selection
%% get matching point from optical flow
prevbb = galRegion2RectXY(region);
[prevPt, currPt] = ofhtOpticalFlowDenseSampling(flows, prevbb);

% remove pts not in previous region
flag = galPtsInRegion(prevPt, region);

prevPt = prevPt(flag, :);
currPt = currPt(flag, :);
if VERBOSITY > 1
    fprintf('prevbb\n');
    disp(prevbb);
    fprintf('prevPt\n');
    disp(prevPt);
    fprintf('currPt\n');
    disp(currPt);
end

%% Check motion magnitude within input region
meanMotionMag = norm(currPt - prevPt) / size(currPt, 1);
if VERBOSITY > 0
    fprintf('meanMotionMag for geometrical proposals: %0.03f\n', meanMotionMag);
end

if meanMotionMag < MOTION_MAG_TH        %return with no ofht proposal
    ofhtRegion = [];
    ofhtDet = [];
    ofhtRotIm = [];
    ofhtBaseAngle = [];
    ofhtConf = [];
    noOfOFHTProp = 0;
    motionFlag = false;         %indicate there is no motion in this frame
    
    return;
end

motionFlag = true;

%% do hough transform
rectWidth = prevbb(3) - prevbb(1);
rectHeight = prevbb(4) - prevbb(2);

minDist = sqrt(rectWidth * rectWidth + rectHeight * rectHeight) * 0.25; 

[ofhtMatrix, noOfPair] = mexOFHTHardVoteLS(single(prevPt), ...
                                           single(currPt), double(minDist)); 

%get normalized ofht confident
ofhtMatrix(:, 5) = ofhtMatrix(:, 5) / single(noOfPair);

noOfOFHTProp = min(size(ofhtMatrix, 1), maxNoOfProp);

% initialize 
ofhtRotIm = cell(noOfOFHTProp, 1);
ofhtBaseAngle = zeros(noOfOFHTProp, 1);
ofhtConf = zeros(noOfOFHTProp, 1);

ofhtRegion = zeros(noOfOFHTProp, 8);
ofhtDet = zeros(noOfOFHTProp, 6);

noOfValidProp = 0;

for i = 1:noOfOFHTProp
    
    % ofht angle smooth condition
    diffAngle = prevMeanDeltaAngle - ofhtMatrix(i, 2);
    if abs(diffAngle) > ANGLE_DIFF_MAX_TH && ~isNewTrack
        if VERBOSITY > 0
            fprintf('ofht prop is rejected by maximum angle!\n');
        end
        continue;
    end
       
    % ofht confident smooth condition
    if ofhtMatrix(i, 5) < CONFIDENCE_RATIO_THRESHOLD * prevMeanAngleConf
        if VERBOSITY > 0
            fprintf('ofht prop is rejected by minimum matching confidence!\n');
        end
        continue;
    end
    
    if abs(diffAngle) < ANGLE_DIFF_MIN_TH
        angleRange = [0 -2.0 2.0];
    else
        angleRange = [0 diffAngle];
    end
    
    angleDet = zeros(length(angleRange), 5);   
    
    maxVal = -10000;
    maxRegion = [];
    maxRotIm = [];
    maxBaseAngle = []; 
    maxIdx = 0;
    
    idx = 0;
    for jAngle = angleRange
        idx = idx + 1;
        ofhtComponent = ofhtMatrix(i, 1:4) + [0, jAngle, 0, 0];       
        
        tmpRegion = double(ofhtCalcSimilarityTranformedRect(ofhtComponent, region));
         
        %Actually, this rot Angle is new base angle in this frame if this
        %ofht proposal will be selected
        baseAngle = prevBaseAngle - ofhtComponent(2);
        
        %rotate image to regular position
        rotIm = imrotate(im, -baseAngle, 'bicubic', 'loose');
        
        %rotate ofht region to regular position
        rotRegion = galRotateRegion(tmpRegion, baseAngle, imWidth, imHeight, rotIm);
                
        %get rectangle from rotated ofht region from regular position / do dense nearby search
        [tempWidth, tempHeight] = model.getTemplateSize;
        [rotRect, ~] = galRegion2RectBFS(rotRegion, rotIm, tempWidth, tempHeight); 
        
        searchRange = 1.0;
        
        [angleDet(idx, :), detScale] = model.det.detectOneFrmLocally(model, rotIm, ...
                                                rotRect, 1, searchRange, 20);
        
        if angleDet(idx, 5) > maxVal
            %maxRegion = tmpRegion;      %BUG: 
            
            maxRotIm = rotIm;
            maxBaseAngle = baseAngle;
            %maxOFHTComponent = ofhtComponent;
            
            maxVal = angleDet(idx, 5);
            maxIdx = idx;
            
            %rotate best angle det back to get best ofht region
            [rotHeight, rotWidth, ~] = size(rotIm);
            
            angleDetRegion = galRectXY2Region(angleDet(idx, 1:4));
            maxRegion = galRotateRegion(angleDetRegion, -baseAngle, rotWidth, rotHeight, im);
        end
            
        
    end % for jAngle = angleRange   
    
    noOfValidProp = noOfValidProp + 1;    
    
    ofhtDet(noOfValidProp, 1:5) = angleDet(maxIdx, :);    
    ofhtRegion(noOfValidProp, :) = maxRegion;  
    ofhtBaseAngle(noOfValidProp) = maxBaseAngle;
    ofhtConf(noOfValidProp) = ofhtMatrix(i, 5);
    
    ofhtRotIm{noOfValidProp} = maxRotIm;  

end %for i = 1:noOfOFHTProp

%prepare the return value
noOfOFHTProp = noOfValidProp;

ofhtRegion = ofhtRegion(1:noOfValidProp, :);
ofhtDet = ofhtDet(1:noOfValidProp, :);
ofhtBaseAngle = ofhtBaseAngle(1:noOfValidProp);         %
ofhtConf = ofhtConf(1:noOfValidProp);    

ofhtRotIm = ofhtRotIm(1:noOfValidProp);         %get list of cell with parentheses
end
