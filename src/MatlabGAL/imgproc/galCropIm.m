function  imRect = galCropIm(im, rect)
% Crop image based on input rectangle.
%
% USAGE
%   imRect = galCropIm(im, rect)
%
% INPUTS
%   im - matrix, [imHeight, imWidth, 3] or [imHeight, imWidth]
%   rect - vector, the format of input rectangle is [x1 y1 x2 y2]
%
% OUTPUTS
%   imRect - matrix, keep the same dimension as im
%
% EXAMPLE
%
% SEE ALSO
%
% TODO
%   (1) Remove the dependence of 'imcrop' function from image processing toolbox
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


imRect = imcrop(im, galRectXY2RectWH(rect));

end
