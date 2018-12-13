function retRect = galResizeRect(rect, scale)
% Resize rectangle and keep the same center point and aspect ratio.
%
% It supports vectorized operation.
%
% USAGE
%   retRect = galResizeRect(inputRect, scale)
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%
% OUTPUTS
%   retRect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
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


rectCenter = galGetRectCenter(rect);
rectSize = galGetRectSize(rect);

retRect = galGenRectFromCenterSize(rectCenter, rectSize * scale);

end
