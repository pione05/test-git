function [state, location] = tracker_pst_initialize(im, region, varargin)
% Initialize the required parameters for the PST tracker from one initial
% annotation.
%
% USAGE
%
% INPUTS
%   im - one frame of the video
%   region - the initial annotated bounding box in region (4 points)
%            representation
%   varargin - up to 4 parameters in this order:
%      varargin{1} - instance of a Config_mb class
%      varargin{2} - pre-loaded SED configuration
%      varargin{3} - pre-loaded MB configuration
%      varargin{4} - pre-loaded optical flow for the image
%
% OUTPUTS
%   state - structure with all the loaded parameters and initialized models
%   location - predicted position for this image (usually the initial
%              bounding box itself)
%
% EXAMPLE
%   tracker_pst_initialize(oneFrame, initRegionBB, config, sedConfig, mbConfig, imFlow)
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


[config, flags, sedModel, ebOpts, mbModel, flows] = inlReadArgs(varargin);
global VERBOSITY;
if VERBOSITY > 0
    fprintf('Starting initialize function...\n');
end
%% Configure
mbTh = config.motionBoundaryThreshold;

initRegion = region;

%% initialization
if inlIsRegionRect(region)
    rotRect = galRegion2RectXY(region);
    angle = 0;
    rotIm = im; 
else
    angle = stObtainMinRotationAngleFromRegion(initRegion);
    [imHeight, imWidth, ~] = size(im);

    rotIm = imrotate(im, -angle, 'bicubic', 'loose');
    rotRegion = galRotateRegion(initRegion, angle, imWidth, imHeight, rotIm);

    [rotRect, ~] = galRegion2RectBFS(rotRegion, rotIm);  
end
if VERBOSITY > 0
    fprintf('initial angle: %d\n', angle);
    fprintf('converted rotated rect:\n');
    disp(rotRect);
end
    
model = TBDModel(rotIm, rotRect, 'hog', 'global'); 
plattModel = [];
if flags.USE_PLATT_MAPPING_FLAG     
    plattModel = PlattModel(model, rotIm, rotRect);
end
                            
%% prepare intermediate data
tracks = Tracks(initRegion, rotRect, angle, config.temporalWindowLength);
if flags.USE_KALMAN_FILTER_FLAG
    tracks.kfDeltaAngle = KalmanFilterLinear(config.A, config.B, config.H, config.xhat, config.P, config.Q, config.R); 
    tracks.kfAngleConf = KalmanFilterLinear(config.A, config.B, config.H, config.xhat, config.P, config.Q, config.R);
end
if VERBOSITY > 0
    fprintf('Finished tracker initialization.\n');
end

% calculate edgebox score
if flags.USE_EDGE_SELECTION_FLAG
    [edgeProb, edgeOrien] = edgesDetect(im, sedModel); 
    
    firstFrmProposal.baseAngle(1) = angle;
    firstFrmProposal.detProp(1, :) = rotRect;

    detEbScores = stCalcEdgeBoxScoreFromConfOrien(edgeProb, edgeOrien,...
        firstFrmProposal, 1, ebOpts, sedModel.opts.nThreads);
    oneEbScore = detEbScores(1);
    tracks = tracks.addEbScore(oneEbScore);
    if VERBOSITY > 0
        fprintf('EB score for frame 1: %.3f\n', oneEbScore);
    end
end
    
%check motion status within region
if flags.USE_MOTION_SELECTION_FLAG && ~isempty(flows)
    mbMotionFlag = stCheckMotionStatus(flows, initRegion, mbTh);
    if VERBOSITY > 0
        fprintf('mbMotionFlag value: %d\n', mbMotionFlag);
    end
    if mbMotionFlag
        nThreads = 4;
        mbInput = cat(3, single(im)/255, flows/10);
        [mbProb, mbOrien] = mbEdgesDetect(mbInput, mbModel);
    
        firstFrmProposal.baseAngle(1) = angle;
        firstFrmProposal.detProp(1, :) = rotRect;
        
        detMbScores = stCalcEdgeBoxScoreFromConfOrien(mbProb, mbOrien,...
            firstFrmProposal, 1, ebOpts, nThreads);

        oneMbScore = detMbScores(1);
        tracks = tracks.addMbScore(oneMbScore);
        if VERBOSITY > 0
            fprintf('MB score for frame 1: %.3f\n', oneMbScore);
        end
    end
end

tracks.prevFlows = flows;
tracks.prevIm = im;

%% prepare return state

state = struct('model', model, 'plattModel', plattModel, 'sedModel', sedModel,...
               'mbModel', mbModel, 'ebOpts', ebOpts, 'tracks', tracks); 
           
location = double(region);

if VERBOSITY > 0
    fprintf('Finished initialize function\n');
end

end % function

function [config, flags, sedModel, ebOpts, mbModel, flows] = inlReadArgs(inputArgs)
    if ~isempty(inputArgs)
        config = inputArgs{1};
    else
        config = Config();
    end
    
    flags = stReadConfigFlags(config);
    
    if length(inputArgs) > 1
        sedConfig = inputArgs{2};
    else
        sedConfig = stLoadModel(config.sedModelPath);
    end
    sedModel = sedConfig.sedModel;
    ebOpts = sedConfig.ebOpts;
    
    if length(inputArgs) > 2
        mbConfig = inputArgs{3};
    else
        mbConfig = load(config.motionBoundaryDetectionModelPath);
    end
    mbModel = mbConfig.model;
    mbModel.opts.nChnsColor = config.motionBoundaryNumberOfColorChannels;
    
    flows = [];
    if flags.USE_GEOMETRIC_PROPOSALS_FLAG || flags.USE_MOTION_SELECTION_FLAG
        if length(inputArgs) > 3
            flows = inputArgs{4};
        end
    end
end

function isRegular = inlIsRegionRect(region)
    regionCorners = zeros(4, 2);
    for i = 0:3
        regionCorners(i+1, :) = [region(i*2+1) region(i*2+2)];        
    end
    
    rectRepr = galRegion2RectWH(region);
    rectCorners = zeros(4, 2);
    rectCorners(1, :) = [rectRepr(1) rectRepr(2)];
    rectCorners(2, :) = [rectRepr(1)+rectRepr(3) rectRepr(2)];
    rectCorners(3, :) = [rectRepr(1) rectRepr(2)+rectRepr(4)];
    rectCorners(4, :) = [rectRepr(1)+rectRepr(3) rectRepr(2)+rectRepr(4)];
    
    numSameCorners = 0;
    for i=1:4
        for j=1:4
            if isequal(regionCorners(i, :), rectCorners(j, :))
                numSameCorners = numSameCorners + 1;
            end
        end
    end
    
    isRegular = false;
    if numSameCorners == 4
        isRegular = true;
    end
end
