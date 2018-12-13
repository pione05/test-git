classdef PlattModel
% Platt model class
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


properties
    A;
    B;
    gScore;
    gScoreRaw;
    posFeat;
    negFeat;
    noOfRealFeat;
end %properties

methods
    function obj = PlattModel(model, im, bb)
        obj = obj.fitPlattModelFeature(model, im, bb);
    end
    
    function score = computePlattScaledScores(obj, detScores)
        score = 1 ./ (1+exp(obj.A .* detScores + obj.B));
    end

    function obj = fitPlattModelFeature(obj, model, im, bb)
        %bb requires [x1,y1,x2,y2] format

        %% parameter setting
        POS_OVERLAP_TH = 0.9;
        NEG_OVERLAP_TH = 0.3;

        %% extract and calculate score for bb
        bbFeat = extFeatFromRect(im, bb, model);     
        bbScore = getScoreFromFeat(model, bbFeat);

        obj.noOfRealFeat = 1;
        bb_center = galGetRectCenter(bb);
        bb_size = galGetRectSize(bb);

        %% prepare for perturbed positive samples
        % select more positive samples
        SAMPLE_CT_POS = 99;
        POS_DIST = 1;
        NEG_DIST = 3;
        [H,W,~] = size(im);

        sample_boxes = zeros(SAMPLE_CT_POS+1,4);
        posScores = zeros(SAMPLE_CT_POS+1, 1);
        obj.posFeat = zeros(numel(bbFeat), SAMPLE_CT_POS+1);

        noOfPos = 1;
        posScores(noOfPos) = bbScore;
        obj.posFeat(:, noOfPos) = bbFeat;       

        % add new random samples
        % for sampleIter = 1:SAMPLE_CT % 65 from MIL CVPR paper.
        totalLoop = 0;
        while (1)
            totalLoop = totalLoop + 1;

            if totalLoop > 10000
                break;
            end

            % find the center of the sample.
            theta = 360.*rand;
            distance = POS_DIST+(NEG_DIST-POS_DIST).*rand; % taken from MIL
            sample_cen_x = bb_center(1) + distance.*cosd(theta);
            sample_cen_y = bb_center(2) + distance.*sind(theta);

            % find the size of the sample?
            %size_entropy = .98;
            sample_sz = ((rand - 1.0) / 100 + 1.0) .* bb_size;
            % get the sample bb
            k_sample = galGenRectFromCenterSize([sample_cen_x,sample_cen_y], sample_sz);
            % clamp it to a reasonable size
            k_sample(1) = galClamp(0,k_sample(1),W);
            k_sample(2) = galClamp(0,k_sample(2),H);
            k_sample(3) = galClamp(0,k_sample(3),W);
            k_sample(4) = galClamp(0,k_sample(4),H);

            % get the sample
            %check the overlap
            overlap = galCalcRectOverlap(bb', k_sample');
            if  overlap < POS_OVERLAP_TH
                %sampleIter = sampleIter - 1;
                continue;
            else
                noOfPos = noOfPos + 1;
                sample_boxes(noOfPos,:) = k_sample;

                obj.posFeat(:, noOfPos) = extFeatFromRect(im, k_sample, model);     
                posScores(noOfPos) = getScoreFromFeat(model, obj.posFeat(:, noOfPos));

                %overlap
                if noOfPos >= SAMPLE_CT_POS+1;
                    break;
                end
            end
        end

        %% Prepare the negative samples
        % paramters
        SAMPLE_CT_NEG = 100;
        POS_DIST = 15;
        NEG_DIST = 100;

        % start with zero features
        %new_neg = zeros([numel(obj.w)+1,SAMPLE_CT]);
        sample_boxes = zeros(SAMPLE_CT_NEG, 4);
        negScores = zeros(SAMPLE_CT_NEG, 1);
        obj.negFeat = zeros(numel(bbFeat), SAMPLE_CT_NEG);

        % add new random samples
        %   for sampleIter = 1:SAMPLE_CT_NEG % 65 from MIL CVPR paper.
        noOfNeg = 0;

        totalLoop = 0;
        while 1
            totalLoop = totalLoop + 1;

            if totalLoop > 10000
                break;
            end

            % find the center of the sample.
            theta = 360.*rand;
            distance = POS_DIST+(NEG_DIST-POS_DIST).*rand; % taken from MIL
            sample_cen_x = bb_center(1) + distance.*cosd(theta);
            sample_cen_y = bb_center(2) + distance.*sind(theta);
            % find the size of the sample?
            size_entropy = .5;
            sample_sz = (1 - .5.*size_entropy).*bb_size + size_entropy.*rand.*bb_size;
            % get the sample bb
            k_sample = galGenRectFromCenterSize([sample_cen_x,sample_cen_y],sample_sz);
            % clamp it to a reasonable size
            k_sample(1) = galClamp(0,k_sample(1),W);
            k_sample(2) = galClamp(0,k_sample(2),H);
            k_sample(3) = galClamp(0,k_sample(3),W);
            k_sample(4) = galClamp(0,k_sample(4),H);

            overlap = galCalcRectOverlap(bb', k_sample');
            if overlap > NEG_OVERLAP_TH 
                continue;
            else
                % get the sample
                noOfNeg = noOfNeg + 1;

                obj.negFeat(:, noOfNeg) = extFeatFromRect(im, k_sample, model);     
                negScores(noOfNeg) = getScoreFromFeat(model, obj.negFeat(:, noOfNeg));        

                sample_boxes(noOfNeg,:) = k_sample;

                %             overlap
                if noOfNeg >= SAMPLE_CT_NEG;
                    break;
                end

            end
        end

        out = [posScores(1:noOfPos); negScores(1:noOfNeg)];
        target = [zeros(noOfPos, 1) + 1; zeros(noOfNeg, 1) - 1];
        prior0 = noOfNeg;
        prior1 = noOfPos;

        [obj.A,obj.B] = platt(out, target, prior0, prior1);
        obj.gScoreRaw = bbScore;
        obj.gScore = 1 ./ (1+exp(obj.A .* bbScore + obj.B));

    end
    
    function obj = updatePlattModelFeature(obj, model, im, bb)
        %% for posFeat updating
        bbFeat = extFeatFromRect(im, bb, model);     
        bbScore = getScoreFromFeat(model, bbFeat);

        SAMPLE_CT_POS = 99;
        posId = 0;
        if obj.noOfRealFeat >= SAMPLE_CT_POS + 1
            posId = 1+ randi(99, 1, 1);
        else
            obj.noOfRealFeat = obj.noOfRealFeat + 1;
            posId = obj.noOfRealFeat;
        end    

        obj.posFeat(:, posId) = bbFeat;

        %% prepare score for positive samples
        posScores = zeros(SAMPLE_CT_POS + 1, 1);
        for pNo = 1:SAMPLE_CT_POS + 1
            posScores(pNo) = getScoreFromFeat(model, obj.posFeat(:, pNo));
        end

        %% prepare score for negtive samples (method 1: use old negative feature)
        SAMPLE_CT_NEG = 100;
        negScores = zeros(SAMPLE_CT_NEG, 1);

        for nNo = 1:SAMPLE_CT_NEG
            negScores(nNo) = getScoreFromFeat(model, obj.negFeat(:, nNo));
        end

        %% fit platt model
        out = [posScores; negScores];
        target = [zeros(SAMPLE_CT_POS + 1, 1) + 1; zeros(SAMPLE_CT_NEG, 1) - 1];
        prior0 = SAMPLE_CT_POS + 1;
        prior1 = SAMPLE_CT_NEG;

        [obj.A, obj.B] = platt(out,target,prior0,prior1);

        obj.gScoreRaw = bbScore;
        obj.gScore = 1 ./ (1+exp(obj.A .* bbScore + obj.B));

    end

end %methods

end %PlattModel class
