function testFullfile
% Test galFullfile function
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% Test fullfile function from Matlab
fullfile('./')
fullfile('../')

fullfile(pwd, '../../../test')

%% 
%extGetFullPath(path)
mfilename('fullpath')

%% Test deprecated galFullfile

galFullfile(pwd, '../../../test')
galFullfile(pwd, '../../../test', 'subtest')

end
