function feat = extFeatFromRectHOG(im, bb, model)
% Extract HOG feature from rectangle
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%span one cell surrounding bounding box
cropBB = [(bb(1)-model.np) (bb(2)-model.np) ...
          (bb(3)+model.np) (bb(4)+model.np)];
imBB = galCropIm(im, cropBB);
imBB = imresize(imBB, [(model.ncy+2)*model.np, (model.ncx+2)*model.np]);
feat = features_32d(double(imBB), model.np);
feat = [feat(:); model.scaleb];

end
