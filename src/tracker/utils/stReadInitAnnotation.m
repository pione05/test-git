function [ initRect, initRegion ] = stReadInitAnnotation( initGtBox )
% Reads the initial annotation bounding box and obtain the rectangle and
% region areas
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    if numel(initGtBox) == 4
        initRect = initGtBox;     
        initRegion = galRectXY2Region(initRect);
    elseif numel(initGtBox) == 8
        initRegion = initGtBox;     
        initRect = galRegion2RectXY(initRegion);
    end
end

