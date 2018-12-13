function overlap = galCalcRectOverlap(rect1, rect2)
% Calculate the overlap between input rectangles. The number of rectangle in
% rect1 and rect2 should be identical.
%
% It supports vectorized operation.
%
% USAGE
%   overlap = galCalcRectOverlap(rect1, rect2)
%
% INPUTS
%   rect1 - [N x 4] or [4 x N] matrix, the format of each row/column is
%           [x1 y1 x2 y2]
%   rect2 - [N x 4] or [4 x N] matrix, the format of each row/column is
%           [x1 y1 x2 y2]
%
% OUTPUTS
%   overlap - scalar or vector, the overlap value between corresponding
%             rectangle in rect1 and rect2.
%
% EXAMPLE
%   rect1 = [100 100 200 200]; rect2 = [150 150 250 250];
%   overlap = galCalcRectOverlap(repmat(rect1, 3, 1), repmat(rect2, 3, 1));
%   overlap = galCalcRectOverlap(repmat(rect1, 3, 1)', repmat(rect2, 3, 1)');
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


% Check the validity of input rectangles
if any(size(rect1) ~= size(rect2))
    galWarning('The size of input rectangle does not match!');
    overlap = 0;
    return;
end

% Check the type of rectangle (column-wise or row-wise; the default is
% column-wise)
if size(rect1, 1) == 4                  %column-wise, the number of row is 4
    L1 = rect1(1,:); L2 = rect2(1,:);
    B1 = rect1(4,:); B2 = rect2(4,:);
    R1 = rect1(3,:); R2 = rect2(3,:);
    T1 = rect1(2,:); T2 = rect2(2,:);
elseif size(rect1, 2) == 4              %row-wise, the number of column is 4
    L1 = rect1(:,1); L2 = rect2(:,1);
    B1 = rect1(:,4); B2 = rect2(:,4);
    R1 = rect1(:,3); R2 = rect2(:,3);
    T1 = rect1(:,2); T2 = rect2(:,2);
else
    galWarning('The format of input rectangle is invalid!');
    overlap = 0;
    return;
end

intersection = (max(0, min(R1, R2) - max(L1, L2) + 1)) .* ...
               (max(0, min(B1, B2) - max(T1, T2) + 1 ));
area1        = (R1-L1+1).*(B1-T1+1);
area2        = (R2-L2+1).*(B2-T2+1);

overlap      = intersection ./ (area1 + area2 - intersection);

end
