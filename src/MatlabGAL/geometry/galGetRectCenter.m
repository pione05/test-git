function rectCenter = galGetRectCenter(rect)
% Get the center of input rectangle.
%
% It supports vectorized operation.
%
% USAGE
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   rectCenter - [N x 2] matrix, the format of each row is [x y]
%
% EXAMPLE
%
% SEE ALSO
%   galGetRectSize, galGetRectWidthHeight
%
% TODO
%   (1) Check the type of rectangle
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


rectCenter = zeros(size(rect,1), 2);

% center x
rectCenter(:,1) = (rect(:,3) + rect(:,1)) ./ 2;
% center y
rectCenter(:,2) = (rect(:,4) + rect(:,2)) ./ 2;

end
