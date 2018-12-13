function path = galFullfile( varargin )
% Generate a path string from the given inputs.
%
% Reference
% http://www.mathworks.com/matlabcentral/fileexchange/28249-getfullpath
%
% This file is deprecated.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


if nargin < 1
    error('galFullfile: input')
else
    path = varargin{1};
end

if nargin == 1
    return;
end

for i = 2:nargin
    path = fullfile(path, varargin{i});
end

%path = extGetFullPath(path);

end
