function flags = stReadConfigFlags( configFile )
% Set the configuration flags according to the config input file
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    flags.USE_MULTIPLE_SCALE_FLAG = logical(configFile.useMultipleScales);
    flags.USE_KALMAN_FILTER_FLAG = logical(configFile.useKalmanFilter);
    flags.USE_PLATT_MAPPING_FLAG = logical(configFile.usePlattMapping);
    flags.USE_EDGE_SELECTION_FLAG = logical(configFile.useEdgeSelection);
    flags.USE_MOTION_SELECTION_FLAG = logical(configFile.useMotionSelection);
    flags.USE_GEOMETRIC_PROPOSALS_FLAG = logical(configFile.useGeometricalProposals);
    
    flags.CACHE_OPTICAL_FLOW = logical(configFile.cacheOpticalFlow);

    flags.SHOW_RESULT_FLAG = logical(configFile.displayVisualResults);
    flags.SAVE_RESULT_FLAG = logical(configFile.saveVisualResults);

end

