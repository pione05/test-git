function pst_demo(vNo, datasetPath, datasetFormatFlag, resultsPath, opticalFlowPath)
% Proposal-Selection Tracker for single object. Track one object in one
% or more videos and save the results on disk.
%
% USAGE
%
% INPUTS
%   All inputs are optional and they are only used to override the
%   configurations found in Config.m. More information about some
%   parameters can be found in Config.m.
%
%   vNo - Index of the video inside the folder of sequences
%   datasetPath - path to the folder of sequences
%   datasetFormatFlag - must be either 'otb' or 'vot'
%   resultsPath - path to the folder where the outputs will be written to
%   opticalFlowPath - path to the folder with the pre-conputed optical flows
%
% EXAMPLE
%   pst_demo
%   pst_demo(1)
%   pst_demo(1, './sequences')
%   pst_demo(1, './sequences', 'otb', './results', './of')
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%

rng('default');
rng(1);

fprintf('Starting PSTracker...\n');

%% Initialization of parameters
%projRootPath = fullfile(mfilename('fullpath'), '../');

[projRootPath, ~, ~] = fileparts(mfilename('fullpath'));

addpath(genpath(projRootPath));
config = Config();
config.displayVisualResults = true;

flags = stReadConfigFlags(config);

global VERBOSITY;
VERBOSITY = config.verbosity;

START_NO = 1;

if nargin > 0; config.videoNumber = galCovtInputParameter(vNo); end
if nargin > 1; config.datasetPath = datasetPath; end
if nargin > 2; config.datasetFormatFlag = datasetFormatFlag; end
if nargin > 3; config.resultsPath = resultsPath; end
if nargin > 4; config.opticalFlowPath = opticalFlowPath; end

vidNamePool = stLoadDatasetVideoNames(config.datasetPath);
[~, nVids] = size(vidNamePool);
outputRootPath = fullfile(config.resultsPath);
galMkDir(outputRootPath);

sedConfig = stLoadModel(config);
mbConfig = load(config.motionBoundaryDetectionModelPath);

fprintf('Finished general initialization\n');

%% Loop for each sequence
tVid = tic;
if config.videoNumber < 0
    iStartVideo = 1;
    iEndVideo = nVids;
else
    iStartVideo = config.videoNumber;
    iEndVideo = config.videoNumber;
end
for iVid = iStartVideo:iEndVideo 
    vidName = vidNamePool{iVid};
    fprintf('Starting process %s...\n', vidName);
    [imgFiles, nFrms] = galGenerateImageList(config.datasetPath, vidName, config.datasetFormatFlag);
    
    rectTracks = cell(nFrms, 1);
    regionTracks = cell(nFrms, 1);
    convertedRectTracks = cell(nFrms, 1);

    %% Initialization
    gts = stReadGroundtruthFile( config.datasetPath, vidName, config.datasetFormatFlag );
    im = galReadRGBIm(imgFiles{START_NO});

    [initRect, initRegion] = stReadInitAnnotation(gts(START_NO, :));
    if VERBOSITY > 0
        fprintf('initRect:\n');
        disp(initRect);
        fprintf('initRegion:\n');
        disp(initRegion);
    end
    
    if flags.USE_GEOMETRIC_PROPOSALS_FLAG || flags.USE_MOTION_SELECTION_FLAG
        inlCheckOFFile(config, flags, vidName);
    end
    
    outputPaths = inlHandleOutputFigures(config, flags, vidName, initRegion, im, START_NO);
    
    [state, location] = tracker_pst_initialize(im, initRegion, config, sedConfig, mbConfig);
    rectTracks{START_NO} = state.tracks.prevDet;
    regionTracks{START_NO} = location;
    [tempWidth, tempHeight] = state.model.getTemplateSize;
    convertedRectTracks{START_NO} = [galRegion2RectBFS(location, im, tempWidth, tempHeight) state.tracks.prevDet(5:6)];
    if VERBOSITY > 0
        inlPrintFrameResults(START_NO, rectTracks{START_NO}, regionTracks{START_NO}, convertedRectTracks{START_NO});
    end

    %% Frame to frame loop
    for jFrm = START_NO+1:nFrms            
        fprintf('[%s]: %04d / %04d ....\n', vidName, jFrm, nFrms);
        %% Reference values from last frame
        im = galReadRGBIm(imgFiles{jFrm});   

        flows = inlLoadOF(config, flags, vidName, jFrm);
        
        [~, gtRegion] = stReadInitAnnotation(gts(jFrm, :));
        [state, location] = tracker_pst_update(state, im, config, flows, outputPaths, gtRegion);
        
        if flags.CACHE_OPTICAL_FLOW && isempty(flows) && ~isempty(state.tracks.prevFlows)
            inlWriteOF(state.tracks.prevFlows, config.opticalFlowPath, vidName, jFrm, config.datasetFormatFlag);
        end
        
        rectTracks{jFrm} = state.tracks.prevDet;
        regionTracks{jFrm} = location;
        [tempWidth, tempHeight] = state.model.getTemplateSize;
        convertedRectTracks{jFrm} = [galRegion2RectBFS(location, im, tempWidth, tempHeight) state.tracks.prevDet(5:6)];
        if VERBOSITY > 0
            inlPrintFrameResults(jFrm, rectTracks{jFrm}, regionTracks{jFrm}, convertedRectTracks{jFrm});
        end

    end %for jFrm = 2:testNoOfFrm     

    %% Performance evaluation
    trackingResults = cell2mat(regionTracks);
    [f1, mo, ovrlps] = galEvalTracksRegion(trackingResults(1:nFrms-START_NO+1, :), gts(START_NO:nFrms, :));
    trackingRectResults = cell2mat(convertedRectTracks);
    [f1Det, moDet, ~] = galEvalTracksRegion(trackingRectResults(1:nFrms-START_NO+1, 1:4), gts(START_NO:nFrms, :));

    totalTime = toc(tVid);
    fprintf('[%s]: time=%0.02f\n', vidName, totalTime);
    fprintf('Geom. region results: f1=%0.03f, mo=%0.03f\n', f1, mo);
    fprintf('Cvt. rect results: f1=%0.03f, mo=%0.03f\n', f1Det, moDet);
    fprintf('Results saved in: %s\n', fullfile(outputRootPath))

    % Use log file to store f1, mo
    logFile = fullfile(outputRootPath, 'log.txt');
    if ~exist(logFile, 'file')
        fid = fopen(logFile, 'w');
        fprintf(fid, 'f1=(2*precision*recall)/(precision+recall), with 50%% or more overlap with groundtruth.\n');
        fprintf(fid, 'mo=mean overlap.\n');
        fprintf(fid, 'iVid\tvName\tf1_reg\tmo_reg\tf1_rect\tmo_rect\ttime\n');
        fclose(fid);
    end
    fid = fopen(logFile, 'a');
    fprintf(fid, '%d\t%s\t%0.03f\t%0.03f\t%0.03f\t%0.03f\t%0.02f\n', iVid, vidName, f1, mo, ...
            f1Det, moDet, totalTime);
    fclose(fid);

    outputFile = fullfile(outputRootPath, [vidName '.txt']);
    dlmwrite(outputFile, trackingResults, 'delimiter', ',', 'precision', '%.3f');

    outputFile = fullfile(outputRootPath, [vidName '_rect.txt']);
    dlmwrite(outputFile, trackingRectResults(:, 1:4), 'delimiter', ',', 'precision', '%.3f');
end %for iVid = 1:nVids  

close all;

end % function

function inlCheckOFFile(config, flags, vidName)
    flows = inlLoadOF(config, flags, vidName, 2);
    if isempty(flows)
        fprintf('Optical flows will be computed online.\n');
        
        if flags.CACHE_OPTICAL_FLOW
            if isempty(config.opticalFlowPath)
                config.opticalFlowPath = fullfile(mfilename('fullpath'), '../optFlow');
            end
            galMkDir(fullfile(config.opticalFlowPath, vidName));
            fprintf('The flows will be cached in: %s\n', fullfile(config.opticalFlowPath, vidName));
        else
            fprintf('The flows will not be cached in disk.\n');
        end
    else
        fprintf('Found pre-computed optical flow files to load.\n');
    end
end

function flows = inlLoadOF(config, flags, vidName, jFrm)
    global VERBOSITY;

    flows = [];
    
    if flags.USE_GEOMETRIC_PROPOSALS_FLAG || flags.USE_MOTION_SELECTION_FLAG
        % Load optical flow file
        if strcmp(config.datasetFormatFlag, 'vot')
            ofFile = fullfile(config.opticalFlowPath, vidName, sprintf('%08d.jpg.flo', jFrm));
        elseif strcmp(config.datasetFormatFlag, 'otb')
            ofFile = fullfile(config.opticalFlowPath, vidName, sprintf('%04d.jpg.flo', jFrm));
        end
        if ~isempty(config.opticalFlowPath)
            try
                flows = readFlowFile(ofFile);
                if VERBOSITY > 0
                    fprintf('Loaded optical flow file for frame %d\n', jFrm);
                end
            catch 
                if VERBOSITY > 0
                    fprintf('Cannot load flow from: %s\n', ofFile);
                end
            end
        end
    end
end

function inlWriteOF(flows, outputOFPath, vidName, jFrm, datasetFormat)
    if strcmp(datasetFormat, 'vot')
        fileName = sprintf('%08d.jpg.flo', jFrm);
    elseif strcmp(datasetFormat, 'otb')
        fileName = sprintf('%04d.jpg.flo', jFrm);
    end

    writeFlowFile(flows, fullfile(outputOFPath, vidName, fileName))
end

function outputPaths = inlHandleOutputFigures(config, flags, vidName, initRegion, im, startNo)
    outputPaths = [];  

    if flags.SAVE_RESULT_FLAG
        rootOutputPath = fullfile(config.resultsPath, vidName);
        outputGeoPath = fullfile(rootOutputPath, 'geometricalProp');
        outputDetPath = fullfile(rootOutputPath, 'detectionProp');
        outputRotPath = fullfile(rootOutputPath, 'rotatedProp');
        outputTrackPath = fullfile(rootOutputPath, 'finalTrack');  
        
        galMkDir(rootOutputPath);
        galMkDir(outputGeoPath);
        galMkDir(outputDetPath);
        galMkDir(outputRotPath);
        galMkDir(outputTrackPath);
        
        outputPaths = {outputGeoPath, outputDetPath, outputRotPath, outputTrackPath};
    end

    if flags.SHOW_RESULT_FLAG || flags.SAVE_RESULT_FLAG
        figVisible = 'off';
        if flags.SHOW_RESULT_FLAG
            figVisible = 'on';
        end
        h1 = figure(1);
        galPlotAnyShape(initRegion, 'g', 1, im);        
        galPlotFrmIndex(startNo);
        regionCenter = galGetRegionCenter(initRegion);
        galPlotPts(regionCenter);
        set(h1, 'Name', 'Intial annotation', 'NumberTitle', 'off', 'Visible', figVisible);
        
        if flags.SAVE_RESULT_FLAG
            outputFile = fullfile(outputTrackPath, sprintf('%08d_track.jpg', 1));
            galSaveFigure(h1, outputFile, [], [], 1.8);
        end
    end
end

function inlPrintFrameResults(frmNo, rectRes, regionRes, convertedRectRes)
    fprintf('\nFinal results for frame %d\n\n', frmNo);
    printRectInfo(rectRes, 'rect');
    printRegionInfo(regionRes, 'region')
    printRectInfo(convertedRectRes, 'converted rect');
end

