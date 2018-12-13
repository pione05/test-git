function printRectInfo(inRect, title)
% Utility function to print an array of rects with an explanation header
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    galSetDefaultVal('title', 'rect');
    fprintf('%s (x1, y1, x2, y2, raw_score, norm_score):\n', title);
    disp(inRect);
end
