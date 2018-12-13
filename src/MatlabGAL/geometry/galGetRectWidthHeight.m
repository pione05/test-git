function [rectWidth, rectHeight] = galGetRectWidthHeight(rect)
% Get the width and height of input rectangle.
%
% It supports vectorized operation.
%
% USAGE
%   [rectWidth, rectHeight] = galGetRectWidthHeight(rect)
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   rectWidth - scalar or vector, the width of rectangle
%   rectHeight - scalar or vector, the height of rectangle
%
% EXAMPLE
%
% SEE ALSO
%   galGetRectSize
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


rectWidth = rect(:,3) - rect(:,1);
rectHeight = rect(:,4) - rect(:,2);

end
