function score = getScoreFromFeat(model, feat)
% Compute the score of a feature column vector
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


featSz = numel(feat)-1;
score = model.w(1:featSz) * feat(1:featSz) + model.b * model.scaleb;

end
