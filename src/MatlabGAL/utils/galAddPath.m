function galAddPath(path)
% Add directory to matlab search path
%
% USAGE
%   galAddPath(path)
%
% INPUTS
%   path: str, full path of the directory
%
% OUTPUTS
%
% EXAMPLE
%
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if ~isdeployed
    addpath(genpath(path));
end

end
