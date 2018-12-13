function retRect = galGenJitteredRect(baseRect, width, height, nRect, isPos)
% Generate jittered rects around base rect 
%
% USAGE
%
% INPUTS
%   rect   - rectangle, [x1, y1, x2, y2] 
%   co     - string, color code (optional)
%   lw     - integer, line weight (optional)
%   im     - matrix, input image (optional)
%
% OUTPUTS
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


%% parameter setting
POS_OVERLAP_TH = 0.9;
NEG_OVERLAP_TH = 0.3;

POS_SMALL_DIST = 1;
POS_BIG_DIST = 3;

NEG_SMALL_DIST = 1;
NEG_BIG_DIST = 3;

POS_SIZE_ENTROPY = 0.98;
NEG_SIZE_ENTROPY = 0.5;

MAX_LOOP_NUM = 10000;

if isPos
    SMALL_DIST = POS_SMALL_DIST;
    BIG_DIST = POS_BIG_DIST;
    OVERLAP_TH = POS_OVERLAP_TH;
    SIZE_ENTROPY = POS_SIZE_ENTROPY;
else
    SMALL_DIST = NEG_SMALL_DIST;
    BIG_DIST = NEG_BIG_DIST;
    OVERLAP_TH = NEG_OVERLAP_TH;
    SIZE_ENTROPY = NEG_SIZE_ENTROPY;
end
 
%% main loop
rectCenter = galGetRectCenter(baseRect);
rectSize = galGetRectSize(baseRect);

ret
totalLoop = 0;
while (1)
    totalLoop = totalLoop + 1;
    
    if totalLoop > MAX_LOOP_NUM
        break;
    end
    
    % find the center of the sample.
    theta = 360 .* rand;
    distance = SMALL_DIST+(BIG_DIST-SMALL_DIST).*rand;  % taken from MIL
    
    sampleCenterX = rectCenter(1) + distance.*cosd(theta);
    sampleCenterY = rectCenter(2) + distance.*sind(theta);
  
    % find the size of the sample?
    %sampleSize = ((rand - 1.0) / 100 + 1.0) .* bb_size;
    
    sampleSize = (1 - 0.5 * SIZE_ENTROPY) .* rectSize + SIZE_ENTROPY .* rand .* rectSize;    
    
    % get the sample bb
    sample = galGenRectFromCenterSize([sampleCenterX, sampleCenterY], sampleSize);
    
    if ~galIsRectValid(sample, width, height)
        continue;
    end
    
    % get the sample
    %check the overlap
    overlap = bb_dotoverlap(bb', sample');
    
    if overlap < POS_OVERLAP_TH
        %sampleIter = sampleIter - 1;
        continue;
    else
        noOfPos = noOfPos + 1;
        sample_boxes(noOfPos,:) = sample;
        
        posFeat(:, noOfPos) = extFeatFromBB(model, im, sample);     
        posScores(noOfPos) = getScoreFromFeat(model, posFeat(:, noOfPos));
        
        sampleSize = (1 - .5.*size_entropy).*bb_size + size_entropy.*rand.*bb_size;
        
        %overlap
        if noOfPos >= SAMPLE_CT_POS+1;
            break;
        end
    end
end




end % function

