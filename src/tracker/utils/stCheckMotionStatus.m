function motionFlag = stCheckMotionStatus(flows, region, motionTh)
% Verify if the motion inside a region is significant
%
% INPUTS
%   flows - dense optical flows from the frame
%   region - area to evaluate the motion
%   motionTh - Threshold for the motion value
%
% OUTPUTS
%   motionFlag - binary flag indicating if the motion is above the
%   threshold or not
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% set default value
galSetDefaultVal('motionTh', 0.5);
global VERBOSITY;

% get dense sampling point for motion calculation
prevbb = galRegion2RectXY(region);
[prevPt, currPt] = ofhtOpticalFlowDenseSampling(flows, prevbb);

% remove pts not in previous region
flag = galPtsInRegion(prevPt, region);

prevPt = prevPt(flag, :);
currPt = currPt(flag, :);

%% Check motion magnitude within input region
meanMotionMag = norm(currPt - prevPt) / size(currPt, 1);
if VERBOSITY > 0
    fprintf('func: stCheckMotionStatus\n')
    fprintf('meanMotionMag: %0.03f, motionThreshold: %0.03f\n', meanMotionMag, motionTh);
end
if VERBOSITY > 1
    fprintf('prevbb\n');
    disp(prevbb);
    fprintf('prevPt\n');
    disp(prevPt);
    fprintf('currPt\n');
    disp(currPt);
end

if meanMotionMag > motionTh
    motionFlag = true;
else
    motionFlag = false;
end    

end %function

