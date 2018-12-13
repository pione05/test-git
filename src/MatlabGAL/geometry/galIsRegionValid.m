function validFlag = galIsRegionValid(region, w, h)
% Verify whether the input region is inside the image or not
%
% It supports vectorized operation.
%
% USAGE
%   validFlag = galIsRegionValid(region, w, h)
%
% INPUTS
%   region - [N x 8/4] matrix, the format of each row is [x1 y1 x2 y2] or
%            [x1 y1 x2 y2 x3 y3 x4 y4]
%   w - the width of image
%   h - the height of image
%
% OUTPUTS
%   validFlag - scalar or vector, the validity of rectangle (true or false)
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


if size(region, 2) == 4
   validFlag = galIsRectValid(region, w, h);
   return;
end

x1 = region(:,1); y1 = region(:,2); x2 = region(:,3); y2 = region(:,4);
x3 = region(:,5); y3 = region(:,6); x4 = region(:,7); y4 = region(:,8);

validFlag = inlCheckVal(x1, w-1, 1) & inlCheckVal(x2, w-1, 1) & ...
            inlCheckVal(x3, w-1, 1) & inlCheckVal(x4, w-1, 1) & ...
            inlCheckVal(y1, h-1, 1) & inlCheckVal(y2, h-1, 1) & ...
            inlCheckVal(y3, h-1, 1) & inlCheckVal(y4, h-1, 1)

end %funciton


function flag = inlCheckVal(val, ub, lb)
    flag = (val >= lb) & (val <= ub);

end %function inlCheckVal
