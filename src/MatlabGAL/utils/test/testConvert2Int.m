function testConvert2Int
% Test galConvert2Int function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% Test valid input
val = ['1'; '2'; '3']
galConvert2Int(val)

val = linspace(1.0, 2.0, 10)
galConvert2Int(val)



end
