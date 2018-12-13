function transRect = ofhtCalcSimilarityTranformedRect(transParams, inputRect)
% Calculate similarity transformed rectangle from input rectangle
% 
% This is a pure matlab implementation of similarity transformation, just
% for demostration. Use it when speed is not the first concern.
%
% USAGE
%   transRect = ofhtCalcSimilarityTranformedRect(transParams, rect)
%
% INPUTS
%   transParams: [scale, theta, dx, dy], vector of similarity transformation parameters
%   inputRect: [x1 y1 x2 y2 x3 y3 x4 y4] vector, coordinators of 4 points
%              of input rectangle 
%       
% OUTPUTS
%   transRect: [x1 y1 x2 y2 x3 y3 x4 y4] vector, coordinators of 4 points
%              of tranformed rectangle 
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    scale = transParams(1); theta = transParams(2); 
    dx = transParams(3); dy = transParams(4);
    
    m = scale * cosd(theta);
    n = scale * sind(theta);
    
    transMatrix = [m -n dx; n m dy];
    
    nPt = round(numel(inputRect) / 2);
    oneVec = ones(1, nPt);
    reshapeRect = [reshape(inputRect, 2, nPt); oneVec];
    
    transRect = transMatrix * reshapeRect;
        
    transRect = transRect(:)';    
    
end


