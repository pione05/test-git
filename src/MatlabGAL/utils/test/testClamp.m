function testClamp
% Test galClamp function
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
valMin = 0; valMax = 10;

valScalar = 11;
galClamp(valScalar, valMin, valMax)

valVector = [-1 1 11];
galClamp(valVector, valMin, valMax)

valMatrix = [-1 1 11; -1 1 11];
galClamp(valMatrix, valMin, valMax)

valMatrix = [-1 1 11; -1 1 11];
galClamp(valMatrix, repmat(valMin, 2, 3), repmat(valMax, 2, 3))


%% Test invalid input
valMatrix = [-1 1 11; -1 1 11];
galClamp(valMatrix, repmat(valMin, 3, 2), repmat(valMax, 2, 3))


end
