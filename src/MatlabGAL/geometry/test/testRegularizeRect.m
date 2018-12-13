function testRegularizeRect
% Test galRegularizeRect function
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

rectAdj = galRegularizeRect(rect1, width, height)
rectAdj = galRegularizeRect(repmat(rect1, 3, 1), width, height)

rect2 = [100 100 2000 2000];
rectAdj = galRegularizeRect(rect2, width, height)
rectAdj = galRegularizeRect(repmat(rect2, 3, 1), width, height)

rectAdj = galRegularizeRect([rect1; rect2], width, height)


%% Test invalid input


end
