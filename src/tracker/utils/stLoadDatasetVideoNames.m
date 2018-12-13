function videoNames = stLoadDatasetVideoNames( datasetPath )
% Read the names of the files inside datasetPath and take them as the
% video names
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


dirData = dir(datasetPath);      % Get the data for the current directory
dirIndex = [dirData.isdir];  % Find the index for directories
fileList = {dirData(dirIndex).name};
videoNames = fileList(3:numel(fileList));

end

