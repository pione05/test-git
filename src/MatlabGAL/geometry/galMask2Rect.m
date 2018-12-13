function rect = galMask2Rect(mask)
% Find the largest rectangle includes input mask.
%
% USAGE
%
% INPUTS
%   mask - matrix, the value larger than 0 represent the input mask
%
% OUTPUTS
%   rect - vector, the larget rectangle includes input mask
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


ind = find(mask);

%store by column
[ycoords, xcoords] = ind2sub(size(mask), ind);

x1 = min(xcoords); x2 = max(xcoords);
y1 = min(ycoords); y2 = max(ycoords);

rect = [x1 y1 x2 y2];

end
