function rectxy = galRegion2RectXY(region)
% Convert input region (8 coordinates or 4 coordinates) to regular rectangle.
%
% It supports vectorized operation.
%
% USAGE
%   rectxy = galRegion2RectXY(region)
%
% INPUTS
%   region - [N x 8/4] matrix, the format of each row is [x1 y1 x2 y2] or
%            [x1 y1 x2 y2 x3 y3 x4 y4]
%
% OUTPUTS
%   rectxy - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% EXAMPLE
%
% SEE ALSO
%   galRegion2RectWH
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if size(region, 2) == 8
    x1 = min(region(:, 1:2:end), [], 2);
    x2 = max(region(:, 1:2:end), [], 2);
    y1 = min(region(:, 2:2:end), [], 2);
    y2 = max(region(:, 2:2:end), [], 2);

    rectxy = [x1 y1 x2 y2];
elseif size(region, 2) == 4
    rectxy = [region(:, 1) region(:, 2) region(:, 3) region(:, 4)];
else
    galWarning('The format of region is invalid!');
    rectxy = [];
    return;
end

end
