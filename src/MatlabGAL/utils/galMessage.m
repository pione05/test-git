function galMessage(message, dispFlag)
% Display information for debugging and logging.
%
% USAGE
%   galMessage(message, dispFlag)
%
% INPUTS
%   message: str, information need to be shown
%   dispFlag: bool, use global setting by default, but can be overwritten
%             by local control (optional)
%
% OUTPUTS
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


global GAL_GLOBAL_DEBUG_VERBOSE_FLAG;
galSetDefaultVal('dispFlag', GAL_GLOBAL_DEBUG_VERBOSE_FLAG);

if dispFlag
    fprintf('%s', sprintf(message));
end

end
