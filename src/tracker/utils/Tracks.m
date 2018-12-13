classdef Tracks
% Hold all the volatile data for PSTracker
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%

    
    properties
        noOfTrackedFrames;
        
        isJustStarted;
        
        prevRegion;
        prevDet;     

        prevBaseAngle;

        meanDeltaAngle;    
        meanAngleConf;

        deltaAngle;        %change rotation angle from previous frame to current frame 
                           %(rotation search range from this delta rotation angle)
        angleConf;                                            

        ofhtConfList;       %set when ofht is selected
        ebScoreList;        %store edgebox score for each frame
        mbScoreList;        %store motion boundary score for each frame
        
        noOfDeltaAngles;
        noOfEbScores;
        noOfMbScores;  
        noOfOfhtConfs;
        
        kfDeltaAngle; 
        kfAngleConf;
        
        prevFlows;
        prevIm;
        
        WINDOW_LENGTH;
    end
    
    methods
        function obj = Tracks(initRegion, rotRect, angle, windowLength)
            obj.noOfTrackedFrames = 1;
            
            obj.isJustStarted = true;
            
            obj.prevRegion = initRegion;
            obj.prevDet = [rotRect 1.0 1.0];     

            obj.prevBaseAngle = angle;

            obj.meanDeltaAngle = 0;    
            obj.meanAngleConf = 0;            
            
            obj.angleConf = 0;  

            obj.deltaAngle = zeros(windowLength, 1);        %change rotation angle from previous frame to current frame 
                                                            %(rotation search range from this delta rotation angle)
            obj.ofhtConfList = zeros(windowLength, 1);       %set when ofht is selected
            obj.ebScoreList = zeros(windowLength, 1);           %store edgebox score for each frame
            obj.mbScoreList = zeros(windowLength, 1);           %store motion boundary score for each frame

            obj.noOfDeltaAngles = 1; % starts in 1 to skip first frame
            obj.noOfEbScores = 0;  
            obj.noOfMbScores = 0;  
            obj.noOfOfhtConfs = 0;
        
            obj.kfDeltaAngle = [];
            obj.kfAngleConf = [];

            obj.prevFlows = [];
            obj.prevIm = [];
            
            obj.WINDOW_LENGTH = windowLength;
        end
        
        function obj = addDeltaAngle(obj, deltaAngle)
            obj.deltaAngle(mod(obj.noOfDeltaAngles, obj.WINDOW_LENGTH) + 1) = deltaAngle;
            obj.noOfDeltaAngles = obj.noOfDeltaAngles + 1;
        end
        
        function obj = addEbScore(obj, ebScore)
            obj.ebScoreList(mod(obj.noOfEbScores, obj.WINDOW_LENGTH) + 1) = ebScore;
            obj.noOfEbScores = obj.noOfEbScores + 1;
        end
        
        function obj = addMbScore(obj, mbScore)
            obj.mbScoreList(mod(obj.noOfMbScores, obj.WINDOW_LENGTH) + 1) = mbScore;
            obj.noOfMbScores = obj.noOfMbScores + 1;
        end
        
        function obj = addOfhtConf(obj, ofhtConf)
            obj.ofhtConfList(mod(obj.noOfOfhtConfs, obj.WINDOW_LENGTH) + 1) = ofhtConf;
            obj.noOfOfhtConfs = obj.noOfOfhtConfs + 1;
        end
        
        function deltaAngleList = getDeltaAngleWindow(obj)
            if obj.noOfDeltaAngles >= obj.WINDOW_LENGTH
                deltaAngleList = obj.deltaAngle;
            else
                deltaAngleList = obj.deltaAngle(1:obj.noOfDeltaAngles);
            end
        end
        
        function ebScoreList = getEbScoreWindow(obj)
            if obj.noOfEbScores >= obj.WINDOW_LENGTH
                ebScoreList = obj.ebScoreList;
            else
                ebScoreList = obj.ebScoreList(1:obj.noOfEbScores);
            end
        end
        
        function mbScoreList = getMbScoreWindow(obj)
            if obj.noOfMbScores >= obj.WINDOW_LENGTH
                mbScoreList = obj.mbScoreList;
            else
                mbScoreList = obj.mbScoreList(1:obj.noOfMbScores);
            end
        end
        
        function confList = getOfhtConfsWindow(obj)
            if obj.noOfOfhtConfs >= obj.WINDOW_LENGTH
                confList = obj.ofhtConfList;
            else
                confList = obj.ofhtConfList(1:obj.noOfOfhtConfs);
            end
        end
        
        function deltaAngle = getLastDeltaAngle(obj)
            deltaAngle = obj.deltaAngle(mod(obj.noOfDeltaAngles - 1, obj.WINDOW_LENGTH) + 1);
        end
    end
    
end

