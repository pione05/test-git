classdef Detector
% Tracking-By-Detection Detector class
%
% It adopts and modifies functions from [1].
%
% REFERENCE
% [1] J. S. Supancic III and D. Ramanan. Self-paced learning for long-term
% tracking. In CVPR, 2013
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


properties (SetAccess = private)
    nmsOverlap = 0.75;

    denseBox;       %for training with surrounding negative samples
    denseFeat;      %for training with surrounding negative samples

    %TODO: add indicator for training feature collection

end %properties

methods
    function obj = Detector()
    end

    function obj = setDenseBox(obj, denseBox)
       obj.denseBox = denseBox;
    end

    function obj = setDenseFeat(obj, denseFeat)
        obj.denseFeat = denseFeat;
    end

    % compute the responce pyrmid for given features
    function [respPyr, featImPyr] = resppyr_with_feats(obj, model, pyrFeat, scales)
        [h,w,nf] = size(model.w);

        %Pre-rotate so that a convolution is handled accordingly
        ww = model.w;
        for i = 1:nf,
            ww(:,:,i) = rot90(ww(:,:,i),2);
        end
        beta = model.b * model.scaleb;

        % Compute the responce for each scale.
        respPyr = {};
        featImPyr = {};

        for s = 1:length(scales)
            featIm = pyrFeat{s};

            % Pad feature map, using an extra cell to handle loss of cell border
            % from feature construction
            padx = w-1;
            pady = h-1;

            % massive padding so we can detect objects which aren't
            % fully in frame.
            featIm  = padarray(featIm, [pady+1 padx+1 0], 0);

            % Score each location
            fsiz = size(featIm(:,:,1));
            resp = zeros(fsiz - [h w] + 1);

            resp = obj.respyr_gather_features(nf, resp, featIm, ww, beta);

            %sz = round(scale.*[h.*model.scaley w.*model.scalex]);

            % store the output
            respPyr{end+1} = resp;
            featImPyr{end+1} = featIm;
        end
    end

    function resp = respyr_gather_features(obj, nf, resp, featIm, ww, beta)

        % Loop over the features
        for i = 1:nf
            resp = resp + conv2(featIm(:,:,i), ww(:,:,i), 'valid');
        end

        resp = resp + beta;
    end

    function [box, feat] = detect_with_resps(obj, model, respPyr, featImPyr, scales)
        [h,w,nf] = size(model.w);

        thresh = model.thresh;

        maxnum = 0;
        for s = 1:length(respPyr)
            maxnum = maxnum + size(respPyr{s},1) * size(respPyr{s},2);
        end

        % Pre-allocate space
        if nargout > 1
            len  = numel(model.w) + numel(model.b);
            feat = uninit(len, maxnum, 'single');
        end

        box = zeros(maxnum,5);
        cnt = 0;

        for s = 1:numel(respPyr),
            % extract features and responses for this pyr level
            resp = respPyr{s};
            featIm = featImPyr{s};
            scale  = model.np * scales(s);
            padx = w-1;
            pady = h-1;


            [y,x] = find(resp >= thresh);

            I  = (x-1)*size(resp,1)+y;
            x1 = (x-1-padx)*scale+1;
            y1 = (y-1-pady)*scale+1;
            x2 = x1 + w*scale - 1;
            y2 = y1 + h*scale - 1;
            J  = cnt+1:cnt+length(I);
            box(J,:) = [x1 y1 x2 y2 resp(I)];
            cnt = cnt+length(I);

            %Write out features if necessary
            if nargout > 1
                for i = 1:length(I)
                    dat = featIm(y(i):y(i)+h-1,x(i):x(i)+w-1,:);

                    feat(:,J(i)) = [dat(:); model.scaleb];
                end
            end
        end

        rand_idxs = randperm(cnt);
        cnt = min(cnt,maxnum);
        box = box(rand_idxs,:);
        if nargout > 1
            feat = feat(:,rand_idxs);
        end
    end

    %This is default function for HOG feature
    function feat = extNegFeatFromImg(obj, model, im, bb, maxNoOfFeat)

        %get pyramid feature for current image
        [pyrFeat, scales] = extPyrFeatFromImg(model, im);

        %get response for each feature
        [respPyr, featImPyr] = obj.resppyr_with_feats(model, pyrFeat, scales);

        [box, feat] = obj.detect_with_resps(model, respPyr, featImPyr, scales);

        %remove feature with higher overlap with bb
        width = bb(3) - bb(1);
        height = bb(4) - bb(2);
        halfThePixels = .5 * width * height;

        posneg = rectint(galRectXY2RectWH(box), galRectXY2RectWH(bb)) < halfThePixels;
        box = box(posneg,:);
        feat = feat(:,posneg);

        %sort by confidence and remove lowest ones
        [void,Ind] = sort(box(:,5),'descend');
        Ind = Ind(1:min(maxNoOfFeat, numel(Ind)));
        box = box(Ind,:);
        feat = feat(:,Ind);

    end %extNegFeatFromImg

    function feat = extNegFeatFromSurrounding(obj, model, im, bb, maxNoOfFeat, isFirstFrm)

        %do scanning first, then extracting features
        [imHeight, imWidth, ~] = size(im);
        radius = max(imHeight, imWidth) / 2.0;
        step = 8;
        dsRect = obj.doDenseSampling([imWidth, imHeight], bb, radius, step);

        %remove feature with higher overlap with bb
        bbWidth = bb(3) - bb(1);
        bbHeight = bb(4) - bb(2);
        halfThePixels = 0.5 * bbWidth * bbHeight;

        negInd = rectint(galRectXY2RectWH(dsRect), galRectXY2RectWH(bb)) < halfThePixels;

        currRect = dsRect(negInd,:);
        noOfRect = size(currRect, 1);

        currScore = zeros(noOfRect, 1);

        currFeat = extFeatFromRect(im, currRect(1, :), model);

        featSz = numel(currFeat)-1;
        currScore(1) = currFeat(1:featSz)'*model.w(1:featSz)' + model.b*model.scaleb;

        feat = zeros(length(currFeat), noOfRect);
        feat(:, 1) = currFeat;

        %extract hog feature on that sliding window
        for rectNo = 2:noOfRect
            currFeat = extFeatFromRect(im, currRect(rectNo, :), model);

            featSz = numel(currFeat)-1;
            currScore(rectNo) = currFeat(1:featSz)'*model.w(1:featSz)' + model.b*model.scaleb;

            feat(:, rectNo) = currFeat;

        end %for rectNo = 1:noOfRect

        box = [currRect currScore];

        %sort by confidence and remove lowest ones
        [void,Ind] = sort(box(:,5),'descend');
        Ind = Ind(1:min(maxNoOfFeat, numel(Ind)));
        box = box(Ind,:);
        feat = feat(:,Ind);
    end

    function detBB = detectOneFrm(obj, model, im, maxNoOfDetPerFrm)
        [pyrFeat, scales] = extPyrFeatFromImg(model, im);

        [respPyr, featImPyr] = obj.resppyr_with_feats(model, pyrFeat, scales);

        [box, feat] = obj.detect_with_resps(model, respPyr, featImPyr, scales);

        detBB = nms(box,obj.nmsOverlap, model.scalex, model.scaley);

        detBB = detBB(1:min(size(detBB,1), maxNoOfDetPerFrm),:);

    end  %detectOneFrm

    function [dsRect] = doDenseSampling(obj, imsize, bb, radius, step)
        galSetDefaultVal('radius', 20);
        galSetDefaultVal('step', 2);

        rectCenter = galGetRectCenter(bb);
        rectSize = galGetRectSize(bb);

        dsRect = zeros(0,4);

        if galIsRectValid(bb, imsize(1), imsize(2))
            dsRect = [dsRect; bb];
        end

        r2 = radius*radius;

        % main loop for find scale
        for iy = -radius:step:radius
            for ix = -radius:step:radius

                if ix*ix+iy*iy > r2
                    continue;
                end

                if iy == 0 && ix == 0
                    continue;               % already put this one at the start
                end

                cen = rectCenter + [ix iy];
                rect = galGenRectFromCenterSize(cen, rectSize);

                if ~galIsRectValid(rect, imsize(1), imsize(2))
                    continue;
                end

                dsRect = [dsRect;rect];
            end %for ix = -radius:step:radius
        end %for iy = -radius:step:radius
    end % end of function

    function [detRect, varargout] = detectOneFrmLocally(obj, model, im, ...
                                baseRect, maxNoOfDet, searchScaleRange, ...
                                searchRadius, searchStep)

        galSetDefaultVal('searchScaleRange', 1.0);
        galSetDefaultVal('searchStep', 2);

        radiusFlag = galSetDefaultVal('searchRadius', 20);

        defaultSearchRadius = searchRadius;

        [tempWidth, tempHeight] = model.getTemplateSize;

        % Gather all valid bounding boxes
        denseRect = [];
        denseScore = [];
        denseScale = [];
        denseFeat = [];

        noOfRange = length(searchScaleRange);

        resizeToTemplateFlag = false;
        for i = 1:noOfRange
            iScale = searchScaleRange(i);

            resizeRect = baseRect * iScale;

            if isempty(denseRect) && i == noOfRange
                resizeToTemplateFlag = true;
            end

            [resizeIm, resizeRect, resizeScale] = ...
                resizeImgAccordingToTemplateSize(im, resizeRect, tempWidth, ...
                                                 tempHeight, resizeToTemplateFlag);

            % skip this scale if not require to resize rect to template size
            if isempty(resizeRect)
                continue
            end

            if radiusFlag       % if set default value / no value input
                searchRadius = round(sqrt((resizeRect(3) - resizeRect(1))^2 + ...
                                    (resizeRect(4) - resizeRect(2))^2) / 4.0);
                searchRadius = galClamp(searchRadius, 20, 100);
            else
                searchRadius = defaultSearchRadius;
            end

            %do dense sampling according to Struck
            [resizeImHeight, resizeImWidth, ~] = size(resizeIm);

            currRect = [];
            while isempty(currRect)
                currRect = obj.doDenseSampling([resizeImWidth, resizeImHeight], ...
                                        resizeRect, searchRadius, searchStep);
                if ~isempty(currRect)
                    break;
                end

                if searchRadius > min(resizeImWidth, resizeImHeight) / 2.0
                    break;
                end

                searchRadius = searchRadius * 2;
            end

            if isempty(currRect)
                continue;
            end

            %Calculate all the local detection results and sort the resutls
            noOfRect = size(currRect, 1);
            currScore = zeros(noOfRect, 1);

            %extract hog feature on that sliding window
            for rectNo = 1:noOfRect
                feat = extFeatFromRect(resizeIm, currRect(rectNo, :), model);
                currScore(rectNo) = getScoreFromFeat(model, feat);

                currRect(rectNo, :) = currRect(rectNo, :) / resizeScale;

                denseFeat = [denseFeat feat];
            end %for rectNo = 1 : size(denseRect, 1)

            if ~isempty(currRect)
                denseRect = [denseRect; currRect];
                denseScore = [denseScore; currScore];
                denseScale = [denseScale; ones(noOfRect, 1) * iScale];
            end

        end % for i = 1:noOfRange

        % prepare return value
        if isempty(denseRect)       %return empty detection results
            detRect = [];

            if nargout == 2
                varargout{1} = [];
            end

            if nargout == 3
                varargout{1} = [];
                varargout{2} = obj;
            end
        else
            %sort the results
            detRect = [denseRect denseScore];

            %prepare training surrounding samples
            if strcmp(model.negFeatCollectionType, 'surrounding')
                obj = obj.setDenseFeat(denseFeat);
                obj = obj.setDenseBox(denseRect);
            end

            %TODO - check return number of debBB
            [~, ind] = sort(detRect(:,5),'descend');
            ind = ind(1:min(maxNoOfDet, numel(ind)));
            detRect = detRect(ind,:);

            if nargout == 2
                varargout{1} = denseScale(ind);
            end

            if nargout == 3
                varargout{1} = denseScale(ind);
                varargout{2} = obj;
            end

        end %if isempty(denseRect)

    end  %detectOneFrmSearchLocal

    function [detBB, varargout] = detectOneFrmLocallyLegacy(obj, model, im, ...
                                basebb, maxNoOfDet, searchScaleRange)
        galSetDefaultVal('maxNoOfDet', 5);
        galSetDefaultVal('searchScaleRange', 1.0);

        [tempWidth, tempHeight] = model.getTemplateSize;

        % Gather all valid bounding boxes
        denseRect = [];
        denseScore = [];
        denseScale = [];

        denseFeat = [];

        noOfRange = length(searchScaleRange);
        for iScale = searchScaleRange
            scalebb = basebb * iScale;

            [scaleImg, scalebb, resizeScale] = resizeImgAccordingToTemplateSize(im, scalebb, tempWidth, tempHeight);

            radius = round(sqrt((scalebb(3) - scalebb(1))^2 + ...
                                (scalebb(4) - scalebb(2))^2) / 4.0);

            %do dense sampling according to Struck
            [h, w, ~] = size(scaleImg);

            %check the validity
            if ~galIsRectValid(scalebb, w, h)  && noOfRange > 1
                fprintf('[%s]: The resize scale is invalid! Skip this scale\n', mfilename('class'));

                %skip this scale
                continue;
            end

            %fix the issue for large search region (347 * 176, carScale)
            searchRadius = min(max(20, radius), 200);

            currRect = [];
            while isempty(currRect)
                currRect = obj.doDenseSampling([w, h], scalebb, searchRadius, 2);
                searchRadius = searchRadius * 2;

                if searchRadius > min(h, w) / 2.0
                    break;
                end
            end

            if isempty(currRect)
                continue;
            end

            %Calculate all the local detection results and sort the resutls
            noOfRect = size(currRect, 1);
            currScore = zeros(noOfRect, 1);
            %extract hog feature on that sliding window
            for rectNo = 1 : noOfRect
                feat = extFeatFromRect(scaleImg, currRect(rectNo, :), model);

                featSz = numel(feat)-1;
                currScore(rectNo) = feat(1:featSz)'*model.w(1:featSz)' + model.b*model.scaleb;

                currRect(rectNo, :) = currRect(rectNo, :) / resizeScale;

                denseFeat = [denseFeat feat];
            end %for rectNo = 1 : size(denseRect, 1)

            if ~isempty(currRect)
                denseRect = [denseRect; currRect];
                denseScore = [denseScore; currScore];
                denseScale = [denseScale; ones(noOfRect, 1) * iScale];
            end
        end % for iScale = searchScaleRange

        %sort the results
        detBB = [denseRect denseScore];

        %prepare training surrounding samples
        if strcmp(model.negFeatCollectionType, 'surrounding')
            obj = obj.setDenseFeat(denseFeat);
            obj = obj.setDenseBox(detBB);
        end

        %TODO - check return number of debBB
        [~, Ind] = sort(detBB(:,5),'descend');
        Ind = Ind(1:min(maxNoOfDet, numel(Ind)));
        detBB = detBB(Ind,:);

        if nargout == 2
            varargout{1} = denseScale(Ind);
        end

        if nargout == 3
            varargout{1} = denseScale(Ind);
            varargout{2} = obj;
        end

    end  %detectOneFrmSearchLocal

end %method

end %Detector class
