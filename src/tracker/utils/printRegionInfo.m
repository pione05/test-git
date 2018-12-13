function printRegionInfo(inRegion, title)
% Utility function to print an array of regions (8 coordinates) with an explanation header
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    galSetDefaultVal('title', 'region');
    fprintf('%s (x1, y1, x2, y2, x3, y3, x4, y4):\n', title);
    disp(inRegion);
end
