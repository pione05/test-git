function stLoadLibraries(libsParentPath)
% Setup the environment and loads libraries/toolboxes
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


fprintf('Loading libraries from %s...\n', libsParentPath);
inlCheckLoadLib('broxOpticalFlow', fullfile(libsParentPath, '3rdparty/broxOpticalFlow'));
inlCheckLoadLib('deqingOpticalFlow', fullfile(libsParentPath, '3rdparty/deqingOpticalFlow'));
inlCheckLoadLib('motionBoundaries', fullfile(libsParentPath, '3rdparty/motionBoundaries'));
inlCheckLoadLib('piotrToolbox', fullfile(libsParentPath, '3rdparty/piotrToolbox'));
inlCheckLoadLib('edgebox', fullfile(libsParentPath, '3rdparty/edgebox'));
fprintf('All libraries loaded successfully!\n');

end

function inlCheckLoadLib(libName, libPath)
    if ~exist(libPath, 'dir')
       error('Library %s not found in %s\n. Please check if the folder pointed in this path exists and if its name is correct (case sensitive).\n', libName, libPath); 
    else
        dirFiles = dir(libPath);
        if length(dirFiles) <= 2
            error('Library %s is empty (folder %s has no files inside). Please check if the library is installed correctly.\n', libName, libPath); 
        end
    end
    galAddPath(libPath);
    fprintf('Loaded %s\n', libName);
end
