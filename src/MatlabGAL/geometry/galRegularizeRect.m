function regRect = galRegularizeRect(rect, width, height)
% Adjust the rectangle according to the constaints of the image
%
% It supports vectorized operation.
%
% USAGE
%   regRect = galRegularizeRect(rect, width, height)
%
% INPUTS
%   region - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   regRect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
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


if all(galIsRectValid(rect, width, height))
    regRect = rect;
else
    x1 = rect(:, 1); y1 = rect(:, 2); x2 = rect(:, 3); y2 = rect(:, 4);

    x1 = galClamp(x1, 1, width-1);
    y1 = galClamp(y1, 1, height-1);
    x2 = galClamp(x2, 1, width-1);
    y2 = galClamp(y2, 1, height-1);

    regRect = [x1 y1 x2 y2];
end

end
