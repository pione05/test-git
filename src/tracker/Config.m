classdef Config
% Class containing all the important parameters that can be tuned for the
% PSTracker.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    properties
        datasetPath = '../sequences';
        % If the dataset contains several sequences, you can choose which
        % one should be used in the tracking by specifying the sequence number.
        % For example, the number 1 corresponds to the first sequence in the
        % folder and so on. You can also test all the videos in the folder
        % by setting the videoNumber as a negative value (e.g. -1)
        videoNumber = 1;
        % Must be either "otb" or "vot" (with quotes). This flag
        % specifies the format of the sequences that will be read (folder hierarchy,
        % name standards, etc.).
        datasetFormatFlag = 'otb';
        resultsPath = '../results';
        % Put an empty value ([] or '') if pre-computed optical flow is not available
        opticalFlowPath = '../optFlow';

        % Binary flags that indicate whether a
        % configuration should be used or not during tracking.
        useMultipleScales = true;
        useGeometricalProposals = true;
        useEdgeSelection = true;
        useMotionSelection = true;
        useKalmanFilter = true;
        usePlattMapping = true;
        
        % If true, and if pre-computed optical flows are not available, the
        % flows computed online will be saved in disk for later usage.
        % By default, the flow will be saved to the path specified in the
        % "opticalFlowPath" above. If the path is empty, the flows will be
        % saved to "./optFlow" folder instead.
        cacheOpticalFlow = true;
        
        displayVisualResults = true;
        saveVisualResults = false;
        verbosity = 0;
        
        % Upper bound on the number of candidate proposals to evaluate
        maxNumberOfDetectionProposals = 5;
        maxNumberOfGeometricalProposals = 5;
        
        % Proposal generation parameters
        maxAngleDiffThreshold = 5.0;
        minAngleDiffThreshold = 2.0;
        confidenceThreshold = 0.6;
        motionMagnitudeThreshold = 0.5;

        % Parameters for motion boundaries
        motionBoundaryThreshold = 0.1;
        motionBoundaryNumberOfColorChannels = 3;
        
        % Parameters for proposal selection
        edgeboxRatioThreshold = 2;
        quantile = 0.01;
        topN = 5;

        % Parameters for the Kalman filter update
        A = 1;
        H = 1;
        B = 0;
        Q = 0.001;
        R = 0.01;
        xhat = 0;
        P = 0.1;

        % number of previous frames to be used to compute statistics from
        temporalWindowLength = 5;

        % Paths to the Edgebox and motion boundary models (relative to their
        % root folders)
        sedModelPath = 'modelBsds.mat';
        motionBoundaryDetectionModelPath = 'model_SintelClean_LDOF_Color+Flow.mat';

        % Range of scale factors to consider for generating proposals
        searchScaleRange = 1.0;
        
        % Edgebox parameters
        sedNThreads = 4;
        sedSharpen = 2;
        sedMultiscale = 0; 
        sedNms = 1;
        
        spOptsNThreads = 4;    % number of computation threads
        spOptsK = 32;          %128;       % controls scale of superpixels (big k -> big sp)
        spOptsAlpha = 0.8;     % relative importance of regularity versus data terms
        spOptsBeta = 0.8;      % relative importance of edge versus color terms
        spOptsMerge = 0;       % set to small value to merge nearby superpixels at end
        spOptsBounds = 0

        ebOptsAlpha = .65;     % step size of sliding window search
        ebOptsBeta  = .75;     % nms threshold for object proposals
        ebOptsMinScore = .01;  % min score of boxes to detect
        ebOptsMaxBoxes = 1e4;
    end
    
    methods
        function obj = Config()
            if obj.useMultipleScales
                obj.searchScaleRange = [0.98 0.99 0.995 1.0 1.005 1.01 1.02];
            end
        end
    end
    
end

