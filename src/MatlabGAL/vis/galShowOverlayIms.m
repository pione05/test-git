function galShowOverlayIms(im1, im2, transFactor, figHandler)
% Show overlay image on current / new figure
%
% USAGE
%
%
% INPUTS
%   im1 - matrix, input image 1
%   im2 - matrix, input image 2
%   transFactor - scalar, the transparent ratio to show the second image
%                 (optional)
%   figHandler - struct, the handler of figure where to show images (optional)
%
%
% OUTPUTS
%
% EXAMPLE
%
%
% SEE ALSO
%   galShowIm
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('transFactor', 0.5);
galSetDefaultVal('figHandler', gcf);

figure(figHandler); clf; set(gca,'position', [0 0 1 1]);

h1 = imagesc(im1); hold on;
h2 = imagesc(im2);

alpha(h2, transFactor);

%axis image;
truesize; axis off;

end
