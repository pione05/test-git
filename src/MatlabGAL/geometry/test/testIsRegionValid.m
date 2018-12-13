function testIsRegionValid
% Test galIsRegionValid function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% Test valid input
width = 1024;
height = 1024;

rect1 = [100 100 1000 1000];
region1 = galRectXY2Region(rect1);

flag = galIsRectValid(region1, width, height)
flag = galIsRectValid(repmat(region1, 3, 1), width, height)

rect2 = [100 100 2000 2000];
region2 = galRectXY2Region(rect2);

flag = galIsRectValid(region2, width, height)
flag = galIsRectValid(repmat(region2, 3, 1), width, height)

flag = galIsRectValid([region1; region2], width, height)

end
