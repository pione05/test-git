function rotRegion = galRotateRegion(region, angle, imWidth, imHeight, rotIm)
% Rotate region under coordination constraint (using center of image as original
% point) on rotated and cropped/non-cropped image
%
% INPUTS:
%   region - 1 x 2N, N represents the input number of point
%   angle - degree, clockwise is potive value
%   imWidth - im width before rotation and after rotation (if apply 'crop'
%             with imrotate)
%   imHeight - im height before rotation and after rotation (if apply 'crop'
%              with imrotate)
%   rotIm - (optional) roated image with 'new' width and height (apply 'loose' with imrotate)
%
% OUTPUTS:
%   rotRegion - rotated region
%
% TODO:
%   (1) Design more general interface for rotation points
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('rotIm', []);

transParams = [1.0 angle 0 0];
nPt = round(numel(region) / 2);

offsetBeforeRotation = -repmat([imWidth/2.0 imHeight/2.0], 1, nPt);

if isempty(rotIm)
    offsetAfterRotation = repmat([imWidth/2.0 imHeight/2.0], 1, nPt);
else
    [rotImHeight, rotImWidth, ~] = size(rotIm);
    offsetAfterRotation = repmat([rotImWidth/2.0 rotImHeight/2.0], 1, nPt);
end

region = region + offsetBeforeRotation;
rotRegion = double(ofhtCalcSimilarityTranformedRect(transParams, region));
rotRegion = rotRegion + offsetAfterRotation;

end
