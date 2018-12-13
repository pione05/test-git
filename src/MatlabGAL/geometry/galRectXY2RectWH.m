function rectwh = galRectXY2RectWH(rectxy)
% Convert rectangle [x1 y1 x2 y2] to rectangle [x1 y1 w h].
%
% It supports vectorized operation.
%
% USAGE
%   rectxy = rectwh2rectxy(rectwh)
%
% INPUTS
%   rectxy - [N x 4] matrix, the format of each row is [x1 y1 x2 y2].
%
% OUTPUTS
%   rectwh - [N x 4] matrix, the format of each row is [x1 y1 w h].
%
% EXAMPLE
%
% SEE ALSO
%   galRectWH2RectXY
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


rectwh = [rectxy(:, 1) ...
          rectxy(:, 2) ...
          rectxy(:, 3) - rectxy(:, 1) ...
          rectxy(:, 4) - rectxy(:, 2)];

end
