function groundtruth = stReadGroundtruthFile( datasetPath, vidName, datasetFormatFlag )
% Load the groundtruth data. This function is able to read from different
% input formats.
%
% INPUTS
%   datasetPath - path to the folder where the sequences are
%   vidName - name of the video to be read
%   datasetFormatFlag - one of the accepted input format names
%
% OUTPUTS
%   groundtruth - loaded groundtruth either in region of rectXT format
%
% SEE ALSO
%   galRegion2RectXY
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if nargin > 2
    if strcmp(datasetFormatFlag, 'otb')
        gtFile = fullfile(datasetPath, vidName, 'groundtruth_rect.txt');
    elseif strcmp(datasetFormatFlag, 'vot')
        gtFile = fullfile(datasetPath, vidName, 'groundtruth.txt');
    else
        error('Unknown dataset format for reading images.');
    end
    groundtruth = importdata(gtFile, ',');
    if size(groundtruth, 2) ~= 4 && size(groundtruth, 2) ~= 8
        groundtruth = importdata(gtFile, '\t');
        if size(groundtruth, 2) ~= 4 && size(groundtruth, 2) ~= 8
            error('Cannot read groundtruth file: %s.\nPlease make sure the groundtruths are according to VOT or OTB standards, and that the coordinates are separated by comma or tab.\n', gtFile);
        end
    end
        
    % OTB uses XYWH standard, but this code uses X1Y1, X2Y2
    if strcmp(datasetFormatFlag, 'otb')
        groundtruth(:,3) = groundtruth(:,1) + groundtruth(:,3);
        groundtruth(:,4) = groundtruth(:,2) + groundtruth(:,4);
    end
else
    % Local standard for testing
    gtFile = fullfile(datasetPath, vidName, 'gt.txt');
    groundtruth = importdata(gtFile, ',');
end
end

