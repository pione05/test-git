function testCalcRegionOverlap
% Test galCalcRegionOverlap function
%
% WARNING:
%   the input order of rect and region matters, so keep rect as the first input
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


addpath(genpath('../'));

region1 = [324.2900 220.1000 346.5100 162.2200 ...
           371.7100 171.9000 349.4900 229.7800];
region2 = [332.5024 166.5007 30.9952  58.9986];

ret1 = mexCalcRegionOverlap(region1, region2)
ret2 = mexCalcRegionOverlap(region2, region1)

%ret1 =
%
%    0.6801    0.1228    0.1971
%
%ret2 =
%
%    0.6807    0.1973    0.1219

region1 = [324.2900 221.1 346.5100 162.2200 ...
           371.7100 171.9000 349.4900 229.7800];
region2 = [324.2900 220.1000 346.5100 162.2200 ...
           371.7100 171.9000 300      200];

ret1 = mexCalcRegionOverlap(region1, region2)
ret2 = mexCalcRegionOverlap(region2, region1)

% ret1 =
% 
%     0.1477    0.6016    0.2507
% 
% ret2 =
% 
%     0.1478    0.2509    0.6013

end
