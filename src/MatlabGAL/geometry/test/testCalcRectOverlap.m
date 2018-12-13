function testCalcRectOverlap
% Test galCalcRectOverlap function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


addpath(genpath('../../'));

%% Valid input testing
rect1 = [100 100 200 200];
rect2 = [150 150 250 250];

%Expected overlap: 0.1461
%column-wise input testing
galCalcRectOverlap(rect1', rect2') 

%row-wise input testing
galCalcRectOverlap(rect1, rect2)

rect1 = repmat(rect1, 3, 1);
rect2 = repmat(rect2, 3, 1);

galCalcRectOverlap(rect1', rect2') 
galCalcRectOverlap(rect1, rect2) 

%% Invalid input testing
rect1 = [100 100 200 200];
rect2 = [150 150 250 250];

galCalcRectOverlap(repmat(rect1, 2, 1), repmat(rect2, 3, 1)) 

galCalcRectOverlap(repmat(rect1, 2, 2), repmat(rect2, 2, 2)) 

end
