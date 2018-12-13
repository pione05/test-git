function [state, location] = tracker_pst_update(state, im, varargin)
% Perform track for one frame and update models. 
%
% USAGE
%
% INPUTS
%   state - structure obtained after initialization
%   im - one frame of the video
%   varargin - up to 4 parameters in this order:
%      varargin{1} - instance of a Config class
%      varargin{2} - pre-loaded optical flow for the image
%      varargin{3} - an array of paths to the figure output folders
%      varargin{4} - the grountruth region for this image (only required
%                    for debugging purposes)
%
% OUTPUTS
%   state - structure representing the state of the tracker with all the
%           updated parameters and models
%   location - the position predicted by PST for this image
%
% EXAMPLE
%   tracker_pst_update(state, oneFrame, config, imFlow, outputPaths, gtRegion)
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


global VERBOSITY;
if VERBOSITY > 0
    fprintf('Starting update function...\n');
end

[config, flags, flows, outputPaths, gtRegion] = inlReadArgs(state, im, varargin);

%% configure parameter
COLOR_CODE = ['r', 'b', 'y', 'm', 'c'];

maxNoOfDetPerFrm = config.maxNumberOfDetectionProposals;
maxNoOfOFHTPerFrm = config.maxNumberOfGeometricalProposals;

mbThreshold = config.motionBoundaryThreshold;

%% get the information from previous frame
model = state.model;

tracks = state.tracks;

tracks.noOfTrackedFrames = tracks.noOfTrackedFrames + 1;

prevRegion = tracks.prevRegion;
prevDet = tracks.prevDet;        
prevBaseAngle = tracks.prevBaseAngle;

prevMeanDeltaAngle = tracks.meanDeltaAngle;
prevMeanAngleConf = tracks.meanAngleConf;
  
sedModel = state.sedModel;
mbModel = state.mbModel;
ebOpts = state.ebOpts;

%prapre proposal
noOfProp = 0;
frmProposal = [];

if VERBOSITY > 0
    fprintf('Starting generating proposals\n');
end

%% Optical flow proposals
noOfOFHTProp = 0;
motionFlag = false;
ofhtBaseAngle = [];
ofhtConf = [];
if flags.USE_GEOMETRIC_PROPOSALS_FLAG && ~isempty(flows)
    if VERBOSITY > 0
        fprintf('Generating geometrical proposals\n');
    end
    [frmProposal, noOfOFHTProp, ofhtBaseAngle, ofhtConf, motionFlag] = stComputeOfhtProposals(model, im, state.plattModel, ...
        prevBaseAngle, prevRegion, maxNoOfOFHTPerFrm, frmProposal, config, flags, ...
        noOfProp, prevMeanAngleConf, tracks.isJustStarted, prevMeanDeltaAngle, ...
        flows);
    noOfProp = noOfProp+noOfOFHTProp;
    if VERBOSITY > 0
        fprintf('Generated %d geometrical proposals\n', noOfOFHTProp);
    end
end

%% Local detection proposal (based on rotated image)
if VERBOSITY > 0
    fprintf('Generating detection proposals\n');
end
[frmProposal, noOfDetProp] = stComputeDetectionProposals(model, im, state.plattModel, prevBaseAngle, prevDet, ...
    config.searchScaleRange, maxNoOfDetPerFrm, frmProposal, flags, noOfProp, prevMeanAngleConf);
noOfProp = noOfProp+noOfDetProp;  
if VERBOSITY > 0
    fprintf('Generated %d detection proposals\n', noOfDetProp);
end

%% All ofht proposal failed, do search rotate image based on
% mean delta angle
noOfRotDetProp = 0;
if noOfOFHTProp == 0 && motionFlag
    if VERBOSITY > 0
        fprintf('Generating rotated proposals (when no geometrical proposals are found)\n');
    end
    [frmProposal, noOfRotDetProp] = stComputeSearchRotateProposals(model, im, state.plattModel, ...
        prevBaseAngle, prevRegion, frmProposal, flags, config.searchScaleRange, ...
        noOfProp, prevMeanAngleConf, prevMeanDeltaAngle);
    noOfProp = noOfProp+noOfRotDetProp; 
    if VERBOSITY > 0
        fprintf('Generated %d rotated proposals\n', noOfRotDetProp);
    end
end
if VERBOSITY > 0
    fprintf('\nAll proposals\n');
    printRectInfo(frmProposal.detProp);
    printRegionInfo(frmProposal.regionProp);
end

%% Select best proposal
[ tracks, frmProposal, selInd, selFlag ] = stSelectBestProposal( im, sedModel, mbModel, ...
    ebOpts, frmProposal, tracks, flows, noOfProp, prevRegion, mbThreshold, config, flags );

tracks.prevDet = frmProposal.detProp(selInd, :);  
tracks.prevRegion = frmProposal.regionProp(selInd, :);  
tracks.prevBaseAngle = frmProposal.baseAngle(selInd);
tracks = tracks.addDeltaAngle(prevBaseAngle - frmProposal.baseAngle(selInd));
tracks.angleConf = frmProposal.angleConf(selInd);
[tempWidth, tempHeight] = model.getTemplateSize;    
if VERBOSITY > 0  
    convRects = zeros(noOfProp, 6);
    for i = 1:noOfProp
        temp_detProp = frmProposal.detProp(i, :);
        temp_rect = [galRegion2RectBFS(frmProposal.regionProp(i, :), im, tempWidth, tempHeight) temp_detProp(5:6)];
        convRects(i, :) = temp_rect;
    end
    fprintf('Proposals in converted rect representation\n');
    printRectInfo(convRects);
end

if flags.SHOW_RESULT_FLAG || flags.SAVE_RESULT_FLAG
    stDisplaySaveFigure(im, tracks.noOfTrackedFrames, frmProposal, tracks,...
        noOfOFHTProp, noOfDetProp, noOfRotDetProp, selInd, prevBaseAngle,...
        ofhtBaseAngle, ofhtConf, COLOR_CODE, flags, outputPaths, gtRegion);
end

%% Update the thresholds for optical flow and geometrical proposals
tracks = stUpdateTrackThresholds( tracks, noOfOFHTProp, selInd, flags );

%% Use rotate image to update detector if applicable    
selRect = tracks.prevDet;
selIm = frmProposal.detIm(selInd);
selIm = selIm{1};

%% Update tracker and prepare for the next frame  
model = model.trainWithOneFrme(selIm, selRect(1:4), 3);
if flags.USE_PLATT_MAPPING_FLAG 
    state.plattModel = state.plattModel.updatePlattModelFeature(model, selIm, selRect(1:4));
end      

%% prepare intermediate results
tracks.isJustStarted = false;

tracks.prevFlows = flows;

tracks.prevIm = im;

%% prepare reture state and location
state.model = model;
state.tracks = tracks;

%region
location = double(tracks.prevRegion);

if VERBOSITY > 0
    fprintf('Finished update function.\n');
end

end %function

function [config, flags, flows, outputPaths, gtRegion] = inlReadArgs(state, im, inputArgs)
    global VERBOSITY;
    
    if ~isempty(inputArgs)
        config = inputArgs{1};
    else
        config = Config();
    end
    
    flags = stReadConfigFlags(config);
    
    flows = [];
    if flags.USE_GEOMETRIC_PROPOSALS_FLAG || flags.USE_MOTION_SELECTION_FLAG
        if length(inputArgs) > 1 && ~isempty(inputArgs{2})
            flows = inputArgs{2};
        else
            prevIm = double(state.tracks.prevIm);
            currIm = double(im);
            if VERBOSITY > 0
                fprintf('Computing optical flow...\n');
            end
            flows = mex_LDOF(prevIm, currIm);
        end
    end
    
    outputPaths = [];
    if length(inputArgs) > 2
        outputPaths = inputArgs{3};
    end
    
    gtRegion = [];
    if length(inputArgs) > 3
        gtRegion = inputArgs{4};
    end
end
