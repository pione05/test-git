function [pyrFeat, scales] = extPyrFeatFromImg(model, im)
% Extract features from pyramidal scales of the image
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


interval = model.interval;
np = model.np;

sc = 2^(1/interval);
imsize = [size(im, 1) size(im, 2)];

max_scale = 1 + floor(log(min(imsize)/(5*np))/log(sc));

pyrFeat = cell(max_scale, 1);
scales = zeros(max_scale, 1);

% our resize function wants floating point values
im = double(im);
for i = 1:interval
    sf = 1/sc^(i-1);
    scaled = mex_resize(im, sf);

    pyrFeat{i} = features_32d(scaled, np);

    scales(i) = sc^(i-1);

    % remaining interals
    for j = i+interval:interval:max_scale
        scaled  = reduce(scaled);
        pyrFeat{j} = features_32d(scaled, np);
        scales(j) = 2 * scales(j-interval);
    end
end

end
