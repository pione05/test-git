function galShowIm(im, figHandler)
% Show image as its original size and without white boarder
%
% USAGE
%   galShowIm(im)
%   galShowIm(im, figHandler)
%
% INPUTS
%   im - matrix, input image
%   figHandler - struct, the handler of figure where to show image (optional)
%
% OUTPUTS
%
% EXAMPLE
%   im = imread('peppers.png');
%   galShowIm(im);
%
% SEE ALSO
%   galShowOverlayIms
%
% REFERENCE
% (1) Show image without white boarder
% http://fr.mathworks.com/matlabcentral/newsreader/view_thread/142402
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('figHandler', gcf);

figure(figHandler); clf; set(gca,'position', [0 0 1 1]);
imagesc(im); truesize; axis off; hold on;


end
