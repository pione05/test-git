function [im, varargout] = galReadRGBIm(imFile)
% Read image from image file and convert to 'RBG' channels if applicable
%
% Read image from image file, if image is gray scale image, then duplicate its
% value for RGB channels
%
% USAGE
%   im = galReadRGBIm(imFile)
%   [im, imWidth, imHeight] = galReadRGBIm(imFile)
%
% INPUTS
%   imgFile - string, image file path
%
% OUTPUTS
%   im - matrix, [imHeight, imWidth, 3]
%   varargout{1} - scalar, the width of input images
%   varargout{2} - scalar, the height of input images
%
% EXAMPLE
%   im = galImReadRGB(imFile)
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


im = imread(imFile);
[imHeight, imWidth, imDim] = size(im);

if imDim == 1
    % duplicate channels
    im(:,:,2) = im(:,:,1);
    im(:,:,3) = im(:,:,1);
end

if nargout == 1

elseif nargout == 3
    varargout{1} = imWidth;
    varargout{2} = imHeight;
else
    error('The number of return variables is invalid!');
end

end
