function retAngle = stObtainMinRotationAngleFromRegion(region)
% Estimate the rotation angle of the given region
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    %% main part
    edgePts = zeros(4, 2);
    vertexPts = zeros(4, 2);
    for i = 0:3
        vertexPts(i+1, :) = [region(i*2+1) region(i*2+2)];        
    end

    for i = 1:4
        j = i+1;
        if j>4
            j=1;
        end
        edgePts(i, :) = (vertexPts(i,:) + vertexPts(j, :)) ./ 2.0; 
    end
    
    regionCenter = galGetRegionCenter(region);    
    plumbLine = [regionCenter; regionCenter(1) 10];

    minAngle = 1000;
    minAxis = [];
    for i = 1:4
        edgeAxis = [regionCenter; edgePts(i, :)];
        angle = inlCalcAngleBetweenTwoLines(edgeAxis, plumbLine); 
        
        if abs(angle) < minAngle
            minAngle = abs(angle);
            retAngle = angle;
            minAxis = edgeAxis;
        end
    end
end % function


function angle = inlCalcAngleBetweenTwoLines(line1, line2)
% line1: 2x2 matrix, [x1 y1; x2 y2]
% line2: 2x2 matrix, [x1 y1; x2 y2]

v1 = line1(1, :) - line1(2, :); 
v2 = line2(1, :) - line2(2, :); 

angle = atan2d( det([v1;v2;]) , dot(v1,v2) );
end


