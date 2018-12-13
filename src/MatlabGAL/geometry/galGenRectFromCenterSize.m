function rect = galGenRectFromCenterSize(rectCenter, rectSize)
% Generate rectangle from center points and rectangle sizes.
%
% It supports vectorized operation.
%
% USAGE
%
% INPUTS
%   rectCenter - [N x 2] matrix, N is the number of points [x y]
%   rectSize - [N x 2] matrix, N is the number of rectangle [width height]
%
% OUTPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


x1 = rectCenter(:,1) - rectSize(:,1)./2;
y1 = rectCenter(:,2) - rectSize(:,2)./2;
x2 = rectCenter(:,1) + rectSize(:,1)./2;
y2 = rectCenter(:,2) + rectSize(:,2)./2;

rect = [x1 y1 x2 y2];

end
