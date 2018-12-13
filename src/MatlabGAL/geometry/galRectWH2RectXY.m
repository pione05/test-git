function rectxy = galRectWH2RectXY(rectwh)
% Convert rectangle [x1 y1 w h] to rectangle [x1 y1 x2 y2]
%
% It supports vectorized operation.
%
% USAGE
%   rectxy = galRectWH2RectXY(rectwh)
%
% INPUTS
%   rectwh - [N x 4] matrix, the format of each row is [x1 y1 w h].
%
% OUTPUTS
%   rectxy - [N x 4] matrix, the format of each row is [x1 y1 x2 y2].
%
% EXAMPLE
%
% See also
%   galRectXY2RectWH
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


rectxy = [rectwh(:, 1) ...
          rectwh(:, 2) ...
          rectwh(:, 1) + rectwh(:, 3) ...
          rectwh(:, 2) + rectwh(:, 4)];

end
