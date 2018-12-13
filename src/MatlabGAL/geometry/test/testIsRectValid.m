function testIsRectValid
% Test galIsRectValid function
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
rect1 = [100 100 1000 1000];
width = 1024;
height = 1024;

flag = galIsRectValid(rect1, width, height)
flag = galIsRectValid(repmat(rect1, 3, 1), width, height)

rect2 = [100 100 2000 2000];
flag = galIsRectValid(rect2, width, height)
flag = galIsRectValid(repmat(rect2, 3, 1), width, height)

flag = galIsRectValid([rect1; rect2], width, height)

end
