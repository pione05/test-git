function [resizeIm, resizeRect, resizeScale] = resizeImgAccordingToTemplateSize( ...
                            im, rect, tempWidth, tempHeight, resizeToTemplateFlag)
% Resize input image and bouding box according to template size.
% This function is used as pre-processing step for extracing feature
% (e.g. HOG) from fixed bounding box, which is supposed to archieve better
% performance than resize bounding box region directly.
%
% USAGE
%   galSetup
%
% INPUTS
%   im - [HxWx3] matrix, could be uint8 or double
%   bb - [x1, y1, x2, y2] vector, desire bounding box
%   tempWidth - template width
%   tempHeight - template height
%
% OUTPUTS
%   rimg - [HxWx3] matrix, resized image
%   rbb - [x1, y1, x2, y2], resize bounding box
%   varargout - resize scale (optional)
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


galSetDefaultVal('resizeToTemplateFlag', false);

[rectWidth, rectHeight] = galGetRectWidthHeight(rect);

if tempWidth * tempHeight > rectWidth * rectHeight   %abnormal situation
    if resizeToTemplateFlag
        resizeIm = im;
        resizeScale = 1.0;

        rectCenter = galGetRectCenter(rect);
        resizeRect = galGenRectFromCenterSize(rectCenter, [tempWidth tempHeight]);

    else                     %do nothing, just skip resize
        resizeIm = [];
        resizeRect = [];
        resizeScale = 1.0;
    end

else  %normal resize
    resizeScale = sqrt((tempWidth * tempHeight) / (rectWidth * rectHeight));

    resizeIm = mex_resize(double(im), resizeScale);
    resizeRect = rect * resizeScale;
end

end %function
