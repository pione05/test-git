function [imgFiles, noOfFrms] = galGenerateImageList(datasetPath, vidName, datasetFormatFlag)
% Load the names of all images inside a folder. The accepted format for
% reading depends on the datasetFormatFlag.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


imagesPath = fullfile(datasetPath, vidName, 'img');
if nargin > 2
    if strcmp(datasetFormatFlag, 'otb')
        imagesPath = fullfile(datasetPath, vidName, 'img');
    elseif strcmp(datasetFormatFlag, 'vot')
        imagesPath = fullfile(datasetPath, vidName);
    else
        error('Unknown dataset format for reading images.');
    end
end

tmpFiles = dir(fullfile(imagesPath, '*.jpg'));

noOfFrms = size(tmpFiles, 1);
if noOfFrms < 1
    error(strcat('No images found in the dataset in the path: ', imagesPath));
end

imgFiles = cell(noOfFrms, 1);
for i = 1: noOfFrms
    imgFiles{i} = fullfile(imagesPath, tmpFiles(i).name);
end

end
