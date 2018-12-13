function galWarning(message)
% Display information for warning information (must be shown)
%
% USAGE
%   galMessage(message, dispFlag)
%
% INPUTS
%   message: str, information need to be shown
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


message = ['WARNING: ' message '\n'];
galMessage(message, true);

end %function
