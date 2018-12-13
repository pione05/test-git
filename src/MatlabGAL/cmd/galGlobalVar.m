function galGlobalVar
% Declare global variables
%
% USAGE
%   galGlobalVar
%
% INPUTS
%
% OUTPUTS
%
% EXAMPLE
%
% SEE ALSO
%
% TODO
%   (1) Use struct to add and remove project dependent global variables
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


% Verbose flag
global GAL_GLOBAL_DEBUG_VERBOSE_FLAG;
GAL_GLOBAL_DEBUG_VERBOSE_FLAG = true;

% Color code
global GAL_GLOBAL_COLOR_CODE;
global GAL_GLOBAL_COLOR_CODE_CELL

%reserve green / white / black
%r: [1 0 0]
%b: [0 0 1]
%y: [1 1 0]
%m: [1 0 1]
%c: [0 1 1]

GAL_GLOBAL_COLOR_CODE = ['r', 'b', 'y', 'm', 'c', 'k', 'w'];


GAL_GLOBAL_COLOR_CODE_RGB = {[1 0 0], [0 0 1], [1 1 0], [1 0 1], [0 1 1], ...
                             [0.5 0.5 0], [0.5 0 0.5], [0 0.5 0.5],...
                             [0.5 0.5 1.0], [0.5 1.0 0.5], [1.0 0.5 0.5],...
                            };

% eps
global GAL_GLOBAL_EPS;
GAL_GLOBAL_EPS = 0.000001;

end
