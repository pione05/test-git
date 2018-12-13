function retPath = galMkDir(path)
% Make directory for input path.
%
% USAGE
%   galMkDir(path)
%   [retPath] = galMkDir(path)
%
% INPUTS
%   path - path to new directory
%
% OUTPUTS
%   retPath - return the path of new directory (optional)
%
% EXAMPLE
%
% SEE ALSO
%
% REFERENCE
%   http://fr.mathworks.com/help/matlab/ref/nargout.html
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if(~exist(path, 'dir')), mkdir(path), end;

if nargout == 1
    retPath = path;
end

end
