function tracks = stUpdateTrackThresholds( tracks, noOfOFHTProp, selInd, flags ) 
% Update angle and confidence values for the next frame
%
% INPUTS
%   tracks - an instance of the Tracks class
%   noOfOFHTProp - number of geometrical proposals
%   selInd - proposal index selected as the best 
%   flags - structure with binary valued flags
%
% OUTPUTS
%   tracks - the updated tracks with the new values
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    global VERBOSITY

     %update ofhtMeanConf, if this ofht proposal has been selected
    if selInd <= noOfOFHTProp
        tracks = tracks.addOfhtConf(tracks.angleConf);          
    end

    %Method 2: Use kalman filter to update        
    %update every frame for delta angle
    if flags.USE_KALMAN_FILTER_FLAG
        if VERBOSITY > 1
            fprintf('deltaAngle\n');
            disp(tracks.deltaAngle);
        end
        tracks.kfDeltaAngle = tracks.kfDeltaAngle.updateKalmanFilter(0, tracks.getLastDeltaAngle());
        tracks.meanDeltaAngle = tracks.kfDeltaAngle.getCurrentState;

        %update only ofht prop has been selected for angle conf
        if selInd <= noOfOFHTProp
            tracks.kfAngleConf = tracks.kfAngleConf.updateKalmanFilter(0, tracks.angleConf);
            tracks.meanAngleConf = tracks.kfAngleConf.getCurrentState;
        end
        
        if VERBOSITY > 0
            fprintf('[Kalman Updating]   meanDeltaAngle : %0.03f / meanAngleConf : %0.04f\n', ...
                tracks.meanDeltaAngle, tracks.meanAngleConf);
        end
    else 
        tracks.meanDeltaAngle = mean(tracks.getDeltaAngleWindow());

        %method 2: use only triggered angle conf (consider maybe not too far away from current frame)
        if tracks.noOfOfhtConfs > 0
            tracks.meanAngleConf = mean(tracks.getOfhtConfsWindow());
        else
            tracks.meanAngleConf = 0;
        end
        if VERBOSITY > 0
            fprintf('[Naive Updating]   meanDeltaAngle : %0.03f / meanAngleConf : %0.04f\n', ...
                    tracks.meanDeltaAngle, tracks.meanAngleConf);
        end
    end
end

