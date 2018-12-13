function validFlag = galIsRectValid(rect, w, h)
% Verify whether the input rectangle is inside the image or not.
%
% It supports vectorized operation.
%
% USAGE
%   validFlag = galIsRectValid(rect, w, h)
%
% INPUTS
%   rect - [N x 4] matrix, the format of each row is [x1 y1 x2 y2]
%   w - the width of image
%   h - the height of image
%
% OUTPUTS
%   validFlag - scalar or vector, the validity of rectangle 
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


x1 = rect(:, 1); y1 = rect(:, 2); x2 = rect(:, 3); y2 = rect(:, 4);

validFlag = inlCheckVal(x1, w-1, 1) & inlCheckVal(x2, w-1, 1) & ...
            inlCheckVal(y1, h-1, 1) & inlCheckVal(y2, h-1, 1);
        
end %funciton


function flag = inlCheckVal(val, ub, lb)
    flag = (val >= lb) & (val <= ub);
        
end %function inlCheckVal
