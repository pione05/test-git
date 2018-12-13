function area = galGetRectArea(rect)
% Calculate the area of rectangle.
%
% It support vectorized operation.
%
% USAGE
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   area - scalar, area of rectangle
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


rectSize = galGetRectSize(rect);

area = rectSize(:, 1) .* rectSize(:, 2);

end
