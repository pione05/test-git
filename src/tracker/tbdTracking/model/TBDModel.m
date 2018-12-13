classdef TBDModel
% Tracking-By-Detection Model class
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
    gtWidth;
    gtHeight;
    gtAspect;

    tpWidth;        %width of template
    tpHeight;       %height of template
    tpScale;        %template scale comparing with ground truth

    Jpos;           %slack

    featType;       %support 'hog'

    negFeatCollectionType;  %support 'global' and 'surrounding'
                            %'global' is specially designed for 'hog'
                            %feature

    %model parameters for hog feature
    ncx;            %no of cell in x coordinate
    ncy;            %no of cell in y coordinate
    nf;             %no of feature dim in each cell
    np;             %no of pixels in each cell

    scaleb;
    scalex;
    scaley;
    interval;       %number of scales in a 2X octave for image pyramid

    %template size control
    minTemplateScale = 0.8; %0.80; %0.6
    minTemplateSize = 400;

    %linear SVM parameter
    w;
    b;

    sym;
    thresh;

    isFirstFrm;
    qp;             %qp slover
    det;            %detector

end % properties

methods
    function obj = TBDModel(im, bb, featType, negFeatCollectionType)
        % TBDModel constructor
        %
        % im: [H x W x 3] matrix
        % bb: [x1 y1 x2 y2] vector
        %
        % TODO:
        % (1) add more parameter for constructor (featType, scaleType)
        %

        galSetDefaultVal('featType', 'hog');

        if strcmp(featType, 'hog')
            galSetDefaultVal('negFeatCollectionType', 'global');
        elseif strcmp(featType, '')
            %to be update
            galSetDefaultVal('negFeatCollectionType', 'surrounding');
        else
            error('[%s]: Invalid feature type!\n', mfilename('class'));
        end

        %other parameters setting
        qpC = 0.1;    %0.1;
        jpos = 1;
        noOfTrainingPass = 3;

        %initial general model
        obj = obj.initModel(bb, featType, qpC, jpos, negFeatCollectionType);

        %train initial model in first frame
        obj = obj.trainWithOneFrme(im, bb, noOfTrainingPass);

        obj = obj.setFirstFrmFlag(false);
    end

    %general constructor
    function obj = initModel(obj, bb, featType, qpC, Jpos, negFeatCollectionType)
        bbWidth = bb(3) - bb(1);
        bbHeight = bb(4) - bb(2);
        obj.gtWidth = bbWidth;
        obj.gtHeight = bbHeight;
        obj.gtAspect = bbWidth / bbHeight;

        obj.featType = featType;
        obj.Jpos = Jpos;
        obj.negFeatCollectionType = negFeatCollectionType;

        if strcmp(featType, 'hog')
            if bbWidth * bbHeight > 10000
                obj.minTemplateScale = 0.5;
            end
            % TODO: set minimun template for single and multiple scale
            if bbWidth * bbHeight < obj.minTemplateSize  % for extreme case: gt size is smaller than minTemplateSize
                templateWidth = bbWidth;
                templateHeight = bbHeight;
            else
                templateWidth = obj.minTemplateScale * bbWidth;
                templateHeight = obj.minTemplateScale * bbHeight;

                if templateWidth * templateHeight < obj.minTemplateSize
                    ratio = sqrt(obj.minTemplateSize / (templateWidth * templateHeight));

                    templateWidth = templateWidth * ratio;
                    templateHeight = templateHeight * ratio;
                end
            end

            %Heuristically select number of pixel in each cell (sbin)
            if (templateWidth * templateHeight > 4000)       %larger than 60*60
                obj.np = 8;
            elseif (templateWidth * templateHeight > 1000)   %larger than 30*30
                obj.np = 6;
            else
                obj.np = 4;
            end

            % TODO: check better solution to set ncy and ncx
            obj.ncy = round(templateHeight / obj.np);
            obj.ncx = round(templateWidth / obj.np);

            % quantified template size
            obj.tpWidth = obj.ncx * obj.np; %templateWidth;
            obj.tpHeight = obj.ncy * obj.np; %templateHeight;

            % TODO: improve the quality of obtaining feature dimension
            %obj.nf = length(extFeat(zeros([3 3 3]), 1, getFeatCode(featType)));

            obj.nf = 32;
            % Main parameters; linearly-scored template and bias
            obj.w = zeros([obj.ncy obj.ncx obj.nf]);
            obj.b = 0;

            % Encode scale factor for bias, width and height
            obj.scaleb = 10;                        %??
            obj.scalex = templateWidth/(obj.ncx*obj.np);  % needed because hog templates cannot exactly
            obj.scaley = templateHeight/(obj.ncy*obj.np); % have same aspect ratio as image templates.

            % Default number of scales in a 2X octave for image pyramid
            obj.interval = 4;

            obj.tpScale = sqrt(single(obj.tpWidth * obj.tpHeight) / single(bbWidth * bbHeight));

        elseif strcmp(featType, '')
            %TODO: add feature information in model
        else
            error('[%s]: Invalid feature type!\n', mfilename('class'));
        end

        % Enforce symmetry
        obj.sym = true;

        % default threshold for hard negative samples mining
        obj.thresh = -1;

        obj.isFirstFrm = true;

        %initial qp solver
        obj.qp = QP(obj, qpC);
        obj.det = Detector();

    end %initModel

    function obj = setFirstFrmFlag(obj, flag)
        obj.isFirstFrm = flag;
    end

    %use to access
    function [tempWidth, tempHeight] = getTemplateSize(obj)
        tempWidth = obj.tpWidth;
        tempHeight = obj.tpHeight;
    end

    function [gtWidth, gtHeight] = getGTSize(obj)
        gtWidth = obj.gtWidth;
        gtHeight = obj.gtHeight;
    end

    function obj = trainWithOneFrme(obj, im, bb, noOfPass)
        galSetDefaultVal('noOfPass', 1);

        maxNoOfNeg = inf;
        updateModelFlag = 1;
        weight = 1;

        % train with one positive sample
        obj = obj.trainOnePos(im, bb, weight, updateModelFlag);


        % train with greedy negative samples
        % TODO: train with negative samples surrounding with bb
        obj.thresh = -weight;
        for iter = 1:noOfPass
            obj = obj.trainNeg(im, bb, weight, updateModelFlag, maxNoOfNeg);
        end

    end % trainWithOneFrme

    function obj = trainOnePos(obj, im, bb, weight, updateModelFlag)
        jpos = obj.Jpos;

        % if we don't have enough room for the sample try to prune non-svs
        if obj.qp.n + 1 >= obj.qp.nmax
            obj.qp = obj.qp.prune;
        end

        % if pruning doesn't work, quit.
        if obj.qp.n + 1 >= obj.qp.nmax
            return;
        end

        [tempWidth, tempHeight] = obj.getTemplateSize;

        if strcmp(obj.featType, 'hog')
            [rim, rbb] = resizeImgAccordingToTemplateSize(im, bb, tempWidth, tempHeight, true);
            feat = extFeatFromRect(rim, rbb, obj);
        elseif strcmp(obj.featType, '')
            feat = extFeatFromRect(im, bb, obj);
        else
            error('[%s]: Invalid feature type!', mfilename('class'));
        end


        %TODO: compose it as one general training function
        obj.qp = obj.qp.write(weight.*jpos*feat, weight.*jpos, jpos, 1);
        obj.qp = obj.qp.opt;

        % update model
        if updateModelFlag
            obj = obj.updateModel;
        end

    end %trainOnePos

    function obj = trainNeg(obj, im, bb, weight, updateModelFlag, maxNoOfNeg)
        maxnum = obj.qp.nmax - obj.qp.n;

        if strcmp(obj.negFeatCollectionType, 'global')  %only for hog feature
            feat = obj.det.extNegFeatFromImg(obj, im, bb, min(maxnum, maxNoOfNeg));
        elseif strcmp(obj.negFeatCollectionType, 'surrounding')
            feat = obj.det.extNegFeatFromSurrounding(obj, im, bb, min(maxnum, maxNoOfNeg), obj.isFirstFrm);
        else
            error('[%s]: Invalid negative feature collection type!\n', mfilename('class'));
        end

        % make sure we don't overfill the cache...
        if size(feat,2) + obj.qp.n >= obj.qp.nmax
            obj.qp = obj.qp.prune();
        end
        assert(size(feat,2) + obj.qp.n <= obj.qp.nmax);

        %TODO: compose it as one general training function
        obj.qp = obj.qp.write(weight.*-feat, weight.*1, 1, 0);
        obj.qp = obj.qp.opt();

        if updateModelFlag
            obj = obj.updateModel;
        end
    end %trainNeg

    % Update model with current QP solution (for HOG?)
    function obj = updateModel(obj)
        obj.w = reshape(obj.qp.w(1:end-1), size(obj.w));
        obj.b = obj.qp.w(end);
    end %updateModel

end %methods

end %TBDModel class
