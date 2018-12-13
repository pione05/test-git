function tbd_demo
% Tracking-By-Detection demo
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Project config
SHOW_TRACKING_RESULT_FLAG = true;

maxNoOfDet = 1;

% Single scale: [1.0]
% Multiple scales: [0.95 0.98 0.99 1.0 1.01 1.02 1.05]
searchScaleRange = [0.95 0.98 0.99 1.0 1.01 1.02 1.05];  

%% Add project path
addpath('../../MatlabGAL/cmd');
galSetup('../');

galMessage('Starting TBDTracker...\n');

%% Load image files and ground truth files
vidName = 'Crossing';
gtFile = fullfile('../../../sequences', vidName, 'groundtruth_rect.txt');
groundtruth = galRectWH2RectXY(importdata(gtFile));
initRect = groundtruth(1, :);

[imgFiles, nFrms] = galGenerateImageList('../../../sequences', vidName);

%% Do TBD Tracking
im = galReadRGBIm(imgFiles{1});
model = TBDModel(im, initRect, 'hog', 'global');

trackingResult = zeros(nFrms, 5);
trackingResult(1, :) = [initRect 1.0];
prevDet = initRect;

%Tracking the following frames
tic
for frmNo = 2:nFrms
    im = galReadRGBIm(imgFiles{frmNo});
    [detbb, ~] = model.det.detectOneFrmLocally(model, im, prevDet(1:4), ...
                    maxNoOfDet, searchScaleRange);

    %update model
    model = model.trainWithOneFrme(im, detbb(1, 1:4), 3);

    %save tracking result
    trackingResult(1, :) = detbb;
    prevDet = detbb(1, 1:4);

    %show tracking result
    if SHOW_TRACKING_RESULT_FLAG
        galShowIm(im);
        galPlotFrmIndex(frmNo);
        galPlotRect(groundtruth(frmNo, :), 'g', 2, ':');
        galPlotRect(prevDet, 'r', 2)

        pause(0.01)
    end
end
totalTime = toc;
spf = totalTime / (nFrms - 1);
fprintf('Time: fps=%0.02f, spf=%0.02f, total=%0.02f\n', 1/spf, spf, totalTime);

%% Check the performance (optional)


end %function
