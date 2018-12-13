function testResizeRect
% Test galResizeRect function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% 
rect = [100 100 200 200];
scale = 0.5;

resizeRect = galResizeRect(rect, scale)
resizeRect = galResizeRect(repmat(rect, 3, 1), scale)

end
