function rectSize = galGetRectSize(rect)
% Get the size of input rectangle
%
% It supports vectorized operation.
%
% USAGE
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   rectSize - [N x 2] matrix, the format of each row is [width height]
%
% EXAMPLE
%
% SEE ALSO
%   galGetRectWidthHeight
%
% TODO
%   (1) Check the type of rect
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


rectSize = zeros(size(rect,1), 2);

% width
rectSize(:,1) = rect(:,3) - rect(:,1);
% height
rectSize(:,2) = rect(:,4) - rect(:,2);

end
