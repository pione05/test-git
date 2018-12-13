function [prevPt, currPt] = ofhtOpticalFlowDenseSampling(flows, prevRect, ...
                                NORMAL_SAMPLING_NUM, NORMAL_BOARDER)
% Do dense sampling on optical flow (i.e. find pair of points in two consecutive
% frames)
%
% INPUTS
%   flows: [imHeight, imWidth, 2] matrix, containing optical flow on x and
%          y direction
%   prevRect: [x1 y1 x2 y2] vector, sampling rectangle region from previous frame
%
% OUTPUTS
%   prevPt: [noOfPts, 2] matrix
%   currPt: [noOfPts, 2] matrix
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Parameter setting
MIN_SIZE = 20;      % minimum side length to set minimum boarder and step
MIN_BOARDER = 0;
MIN_STEP = 1;

galSetDefaultVal('NORMAL_SAMPLING_NUM', 10);
galSetDefaultVal('NORMAL_BOARDER', 5);

%% main procedure
ofx = flows(:,:,1); ofy = flows(:,:,2);
[imgHeight, imgWidth] = size(ofx);
x1 = galClamp(prevRect(1), 1, imgWidth);
y1 = galClamp(prevRect(2), 1, imgHeight);
x2 = galClamp(prevRect(3), 1, imgWidth);
y2 = galClamp(prevRect(4), 1, imgHeight);

if x2-x1 < MIN_SIZE
    spanx = MIN_BOARDER;
    stepx = MIN_STEP;
else
    spanx = NORMAL_BOARDER;
    stepx = floor((x2 - x1 - 2 * spanx) / NORMAL_SAMPLING_NUM);
end

if y2-y1 < MIN_SIZE
    spany = MIN_BOARDER;
    stepy = MIN_STEP;
else
    spany = NORMAL_BOARDER;
    stepy = floor((y2 - y1 - 2 * spany) / NORMAL_SAMPLING_NUM);
end
    
x1 = ceil(x1);
y1 = ceil(y1);
x2 = floor(x2);
y2 = floor(y2);
deltax = ofx(y1+spany:stepy:y2-spany, x1+spanx:stepx:x2-spanx, 1);
deltay = ofy(y1+spany:stepy:y2-spany, x1+spanx:stepx:x2-spanx, 1);

% method 2: meshgrid
[X, Y] = meshgrid(x1+spanx:stepx:x2-spanx, y1+spany:stepy:y2-spany);
newX = X + deltax;
newY = Y + deltay;
prevPt = [X(:) Y(:)];
currPt = [newX(:) newY(:)];

% function
