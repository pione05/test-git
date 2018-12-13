function retVal = galClamp(val, valMin, valMax)
% Adjust input value to lay between [valMin, valMax].
%
% It supports vectorized operation.
%
% USAGE
%   retVal = galClamp(val, valMin, valMax)
%
% INPUTS
%   val - scalar or vector or matrix, input value
%   valMin - scalar or vector or matrix, the lower bound of input value
%   valMax - scalar or vector or matrix, the upper bound of input value
%
% OUTPUTS
%   retVal - scalar or vector or matrix, adjusted value
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


retVal = val;

if numel(valMin) ~= 1 || numel(valMax) ~= 1
    if ~isequal(size(val), size(valMax), size(valMin))
        galWarning('The dimensions of inputs do not match!');
        return;
    end
end

retVal = max(retVal, valMin);
retVal = min(retVal, valMax);

end
