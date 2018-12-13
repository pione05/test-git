function setFlag = galSetDefaultVal(argName, defaultValue)
% Set default value for function parameters.
%
% USAGE
%   galSetDefaultVal(argName, defaultValue)
%   setFlag = galSetDefaultVal(argName, defaultValue)
%
% INPUTS
%   argName: string, variable name in caller function
%   defaultValue: default value
%
% OUTPUTS
%   setFlag: bool, to show whether the default value is set or not. It may be
%            useful in some situations.
%
% EXAMPLE
%   galSetDefaultVal('imWidth', 1000);
%
%   if ~galSetDefaultVal('resizeFactor', 0.48)
%       resizeFactor = resizeFactor * 0.48;
%   end
%
% SEE ALSO
%
% Reference
% (1) Another elegant method to set default value
% http://blogs.mathworks.com/loren/2009/05/05/nice-way-to-set-function-defaults/
% (2) inspired source code for setting default value
% http://fr.mathworks.com/matlabcentral/fileexchange/27056-set-default-values
%
%
% KEY POINTS
% (1) evalin('caller', ...) can evaluate matlab expression from caller function
% (2) || is short-cut operation, so the order of '~exist()' and
%     'isempty()' matters
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if evalin('caller', ['~exist(''', argName, ''', ''var'')']) || ...
   evalin('caller', ['isempty(eval(''', argName, '''))'])
    assignin('caller', argName, defaultValue);
    setFlag = true;
else
    setFlag = false;
end

end
