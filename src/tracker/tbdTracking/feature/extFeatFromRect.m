function feat = extFeatFromRect(im, bb, model)
% Extract feature from rectangle based on feature type
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


featType = model.featType;

if strcmp(featType, 'hog')
    feat = extFeatFromRectHOG(im, bb, model);
elseif strcmp(featType, '')
    %to be updated
else
    error('Invalid feature type!');
end

end
