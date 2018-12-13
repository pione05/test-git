function retVal = galConvert2Int(val)
% Convert the input value to integer type
%
%
% USAGE
%   retVal = galConvert2Int(val)
%
% INPUTS
%   val - scalar or vector or matrix, input value
%
% OUTPUTS
%   retVal - scalar or vector or matrix, integer value after converting
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


if ischar(val)
    retVal = uint8(str2num(val));
else
    retVal = uint8(val);
end

end
